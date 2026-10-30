import 'dart:convert';
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
        !path.endsWith('/updates/download')) {
      access.ensureOnline();
    }
    request.headers['x-archive-platform'] = access.platform;
    request.headers['x-archive-build'] = '${access.build}';
    final response = await _delegate.send(request);
    if (response.statusCode != 426) return response;
    try {
      final body = jsonDecode(await response.stream.bytesToString()) as Map;
      await access.accept(body['manifest'] as String);
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
  ArchiveApiClient(super.host, this.access, {http.Client? httpClient})
    : super(httpClientOverride: _VersionedHttp(access, httpClient));
  final ClientAccess access;
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
