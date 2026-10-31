import 'dart:convert';
import 'dart:typed_data';
import 'package:archive_shared/client_protocol.dart';
import 'package:archive_client/archive_client.dart';
import 'package:http/http.dart' as http;
import 'client_access.dart';

class _VersionedHttp extends http.BaseClient {
  _VersionedHttp(this.access, http.Client? delegate)
    : _delegate = delegate ?? http.Client();
  final ClientAccess access;
  final http.Client _delegate;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    if (!path.endsWith('/updates/check') &&
        !path.endsWith('/updates/download') &&
        !path.contains('/client-updates/v1/')) {
      access.ensureOnline();
    }
    request.headers['x-archive-platform'] = access.platform;
    request.headers['x-archive-build'] = '${access.build}';
    request.headers['x-archive-protocol'] = '${access.protocol}';
    final response = await _delegate.send(request);
    if (response.statusCode != 426) return response;
    try {
      final body = jsonDecode(await response.stream.bytesToString()) as Map;
      if (body['protocols'] != null) {
        await access.acceptCompatibility(
          UpdateCompatibility.fromJson(Map<String, dynamic>.from(body)),
        );
      } else {
        await access.acceptCompatibility(
          UpdateCompatibility(
            protocols: [1],
            manifest: body['manifest'] as String,
          ),
        );
      }
    } catch (_) {
      access.checkFailed();
    }
    throw const ClientOfflineException();
  }

  @override
  void close() => _delegate.close();
}

/// All normal RPCs, including auth refresh, pass the gate before sending data.
/// The signed update channel deliberately remains available without auth.
class ArchiveApiClient extends Client {
  factory ArchiveApiClient(
    String host,
    ClientAccess access, {
    http.Client? httpClient,
  }) => ArchiveApiClient._(host, access, _VersionedHttp(access, httpClient));
  ArchiveApiClient._(super.host, this.access, this._http)
    : _base = Uri.parse(host),
      super(httpClientOverride: _http);
  final _VersionedHttp _http;
  final Uri _base;
  final ClientAccess access;
  Future<http.Response> _updateGet(String path, int limit) async {
    final response = await _http
        .send(http.Request('GET', _base.resolve(path)))
        .timeout(const Duration(seconds: 10));
    final bytes = BytesBuilder(copy: false);
    await for (final part in response.stream.timeout(
      const Duration(seconds: 20),
    )) {
      if (bytes.length + part.length > limit) {
        throw const FormatException('Завелика відповідь сервера оновлень.');
      }
      bytes.add(part);
    }
    return http.Response.bytes(
      bytes.takeBytes(),
      response.statusCode,
      headers: response.headers,
    );
  }

  Future<String?> checkUpdates() async {
    final response = await _updateGet(archiveUpdateCheckPath, 256 * 1024);
    if (response.statusCode == 404) {
      // Only the original protocol may use a server predating the bootstrap.
      final raw = await callServerEndpoint<String?>(
        'updates',
        'check',
        {},
        authenticated: false,
      );
      await access.acceptCompatibility(
        UpdateCompatibility(protocols: [1], manifest: raw),
      );
      return raw;
    }
    if (response.statusCode != 200) {
      throw const FormatException('Не вдалося перевірити сумісність сервера.');
    }
    final info = UpdateCompatibility.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    await access.acceptCompatibility(info);
    return info.manifest;
  }

  Future<ByteData> downloadUpdate(String hash, int offset) async {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
        offset < 0 ||
        offset % (256 * 1024) != 0) {
      throw const FormatException('Некоректна частина оновлення.');
    }
    final response = await _updateGet(
      '$archiveUpdateDownloadPath/$hash/$offset',
      256 * 1024,
    );
    if (response.statusCode == 404) {
      return callServerEndpoint<ByteData>('updates', 'download', {
        'sha256': hash,
        'offset': offset,
      }, authenticated: false);
    }
    if (response.statusCode != 200 || response.bodyBytes.length > 256 * 1024) {
      throw const FormatException('Не вдалося завантажити оновлення.');
    }
    return ByteData.sublistView(response.bodyBytes);
  }

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) {
    if (endpoint != 'updates') access.ensureOnline();
    return super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    );
  }

  @override
  dynamic callStreamingServerEndpoint<T, G>(
    String endpoint,
    String method,
    Map<String, dynamic> args,
    Map<String, Stream> streams, {
    bool authenticated = true,
  }) {
    if (!access.onlineAllowed) {
      if (T == Stream<G>) {
        return Stream<G>.error(const ClientOfflineException());
      }
      return Future<G>.error(const ClientOfflineException());
    }
    return super.callStreamingServerEndpoint<T, G>(
      endpoint,
      method,
      {
        ...args,
        if (endpoint == 'archiveSync' && method == 'watch') ...{
          'clientPlatform': access.platform,
          'clientBuild': access.build,
          'clientProtocol': access.protocol,
        },
      },
      streams,
      authenticated: authenticated,
    );
  }

  @override
  void close() {
    super.close();
    access.dispose();
  }
}
