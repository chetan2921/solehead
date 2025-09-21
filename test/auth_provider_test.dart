import 'package:flutter_test/flutter_test.dart';
import 'package:solehead/providers/auth_provider.dart';

void main() {
  group('AuthProvider Login Flow Tests', () {
    test(
      'should update isLoggedIn state after successful mock login',
      () async {
        final authProvider = AuthProvider();

        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Initial state should be false
        expect(authProvider.isLoggedIn, false);
        expect(authProvider.user, null);

        // Perform mock login
        final result = await authProvider.mockLogin('testuser');

        // Check the result
        expect(result, true);
        expect(authProvider.isLoggedIn, true);
        expect(authProvider.user, isNotNull);
        expect(authProvider.user?.username, 'testuser');
        expect(authProvider.error, null);
      },
    );
  });
}
