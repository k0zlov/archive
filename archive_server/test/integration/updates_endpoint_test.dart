import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Windows updates before sign-in', (sessions, endpoints) {
    test(
      'an unauthenticated client can check releases; invalid binary paths are refused',
      () async {
        final unauthenticated = sessions.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );
        // A successful call proves that no authenticated archive session is required.
        await expectLater(endpoints.updates.check(unauthenticated), completes);
        await expectLater(
          endpoints.updates.download(unauthenticated, '../passwords.yaml', 0),
          throwsA(anything),
        );
      },
    );
  });
}
