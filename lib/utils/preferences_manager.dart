import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Singleton pattern
  static PreferencesManager? _instance;
  static SharedPreferences? _prefs;

  PreferencesManager._();

  static Future<PreferencesManager> getInstance() async {
    _instance ??= PreferencesManager._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // First time app launch
  Future<bool> isFirstTime() async {
    return _prefs?.getBool(_isFirstTimeKey) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool(_isFirstTimeKey, value);
  }

  // Login state
  Future<bool> isLoggedIn() async {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_isLoggedInKey, value);
  }

  // Clear all preferences (for logout or reset)
  Future<void> clear() async {
    await _prefs?.clear();
  }

  // Clear only auth-related preferences
  Future<void> clearAuth() async {
    await _prefs?.remove(_isLoggedInKey);
  }
}
