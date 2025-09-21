import 'package:flutter/services.dart';

class TestNavigationHelper {
  static const MethodChannel _channel = MethodChannel(
    'com.example.solehead/test',
  );

  /// Clear all shared preferences to simulate first-time app launch
  static Future<void> clearSharedPreferences() async {
    try {
      await _channel.invokeMethod('clearSharedPreferences');
      print(
        'Shared preferences cleared - app will show intro screen on next launch',
      );
    } catch (e) {
      print('Error clearing shared preferences: $e');
    }
  }

  /// Simulate logout by clearing only auth-related preferences
  static Future<void> clearAuthPreferences() async {
    try {
      await _channel.invokeMethod('clearAuthPreferences');
      print('Auth preferences cleared - user will need to login again');
    } catch (e) {
      print('Error clearing auth preferences: $e');
    }
  }

  /// Check current preference states for debugging
  static Future<Map<String, dynamic>> getPreferencesState() async {
    try {
      final result = await _channel.invokeMethod('getPreferencesState');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting preferences state: $e');
      return {};
    }
  }
}
