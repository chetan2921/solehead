import 'package:http/http.dart' as http;
import 'constants.dart';

class ServerStatus {
  static bool _postsEndpointAvailable = true; // Production API is available
  static bool _usersEndpointAvailable = true; // Production API is available
  static bool _sneakersEndpointAvailable = true; // Production API is available
  static bool _hasChecked = false;

  static bool get postsEndpointAvailable => _postsEndpointAvailable;
  static bool get usersEndpointAvailable => _usersEndpointAvailable;
  static bool get sneakersEndpointAvailable => _sneakersEndpointAvailable;
  static bool get isInDemoMode =>
      !_postsEndpointAvailable && ApiConstants.isDevelopmentMode;

  /// Check which endpoints are available on the server
  static Future<void> checkEndpoints() async {
    if (_hasChecked) return;

    try {
      // Check posts endpoint
      final postsResponse = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/posts'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      _postsEndpointAvailable = postsResponse.statusCode != 404;
    } catch (e) {
      _postsEndpointAvailable = false;
    }

    try {
      // Check users endpoint
      final usersResponse = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/users'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      _usersEndpointAvailable = usersResponse.statusCode != 404;
    } catch (e) {
      _usersEndpointAvailable = false;
    }

    try {
      // Check sneakers endpoint
      final sneakersResponse = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/sneakers'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      _sneakersEndpointAvailable = sneakersResponse.statusCode != 404;
    } catch (e) {
      _sneakersEndpointAvailable = false;
    }

    _hasChecked = true;

    if (ApiConstants.isDevelopmentMode) {
      print('🔍 Server Status Check:');
      print(
        '  Posts endpoint: ${_postsEndpointAvailable ? '✅ Available' : '❌ Not found'}',
      );
      print(
        '  Users endpoint: ${_usersEndpointAvailable ? '✅ Available' : '❌ Not found'}',
      );
      print(
        '  Sneakers endpoint: ${_sneakersEndpointAvailable ? '✅ Available' : '❌ Not found'}',
      );
      print('  Demo mode: ${isInDemoMode ? '✅ Active' : '❌ Inactive'}');
    }
  }

  /// Reset the check status (useful for testing)
  static void reset() {
    _hasChecked = false;
    _postsEndpointAvailable = false;
    _usersEndpointAvailable = false;
    _sneakersEndpointAvailable = false;
  }
}
