import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    print('AuthProvider: _initializeAuth() called');
    _setLoading(true);
    try {
      bool savedLoginState = false;
      try {
        final prefs = await SharedPreferences.getInstance();
        savedLoginState = prefs.getBool('isLoggedIn') ?? false;
        print('AuthProvider: Loaded saved login state: $savedLoginState');
      } catch (e) {
        print(
          'AuthProvider: Failed to access SharedPreferences during init: $e',
        );
        // If SharedPreferences fails, assume not logged in
        savedLoginState = false;
      }

      _isLoggedIn = savedLoginState;
      print('AuthProvider: Set _isLoggedIn to: $_isLoggedIn');

      if (_isLoggedIn) {
        try {
          await _loadUserProfile();
        } catch (e) {
          print(
            'AuthProvider: Failed to load user profile, but keeping logged in state: $e',
          );
          // Don't clear the login state immediately - let the user try to use the app
          // The API calls will handle auth failures appropriately
        }
      }
    } catch (e) {
      print('AuthProvider: Error during initialization: $e');
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
      print(
        'AuthProvider: _initializeAuth completed, calling notifyListeners()',
      );
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _user = await AuthService.getUserProfile();
      notifyListeners();
    } catch (e) {
      print('Failed to load user profile: $e');
      // Don't immediately log out on profile load failure
      // The user might still be authenticated, just can't load profile
      _setError('Failed to load user profile: ${_getErrorMessage(e)}');

      // Only clear login state if it's a clear authentication failure
      if (e.toString().contains('401') ||
          e.toString().contains('Authentication')) {
        _isLoggedIn = false;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
        } catch (prefsError) {
          print(
            'AuthProvider: Failed to update SharedPreferences during profile load error: $prefsError',
          );
        }
      }
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await AuthService.register(
        email: email,
        password: password,
        username: username,
      );

      await _setLoggedInState(true);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    print('AuthProvider: login() called with email: $email');
    _setLoading(true);
    _clearError();

    try {
      _user = await AuthService.login(email: email, password: password);
      print('AuthProvider: Login successful, setting logged in state');
      await _setLoggedInState(true);
      print('AuthProvider: Login completed successfully');
      return true;
    } catch (e) {
      print('AuthProvider: Login failed: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> mockLogin(String username) async {
    print('AuthProvider: mockLogin() called with username: $username');
    _setLoading(true);
    _clearError();

    try {
      _user = await AuthService.mockLogin(username);
      print('AuthProvider: Mock login successful, setting logged in state');
      await _setLoggedInState(true);
      print('AuthProvider: Mock login completed successfully');
      return true;
    } catch (e) {
      print('AuthProvider: Mock login failed: $e');
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({String? username, String? email}) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await AuthService.updateProfile(username: username, email: email);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await AuthService.uploadProfilePhoto(filePath);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await AuthService.logout();
      await _setLoggedInState(false);
      _user = null;
    } catch (e) {
      print('AuthProvider: Error during logout: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _setLoggedInState(bool loggedIn) async {
    print('AuthProvider: _setLoggedInState called - loggedIn: $loggedIn');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', loggedIn);
      print('AuthProvider: SharedPreferences updated successfully');
    } catch (e) {
      print('AuthProvider: Failed to update SharedPreferences: $e');
      // Don't let SharedPreferences failure prevent login state update
      // This handles cases where the binding isn't initialized (tests, edge cases)
    }

    _isLoggedIn = loggedIn;
    print('AuthProvider: State updated - _isLoggedIn: $_isLoggedIn');
    print('AuthProvider: About to call notifyListeners()');
    notifyListeners();
    print('AuthProvider: notifyListeners() called');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('user-not-found')) {
      return 'No user found with this email address';
    } else if (error.toString().contains('wrong-password')) {
      return 'Incorrect password';
    } else if (error.toString().contains('email-already-in-use')) {
      return 'Email address is already in use';
    } else if (error.toString().contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.toString().contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection';
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }

  void clearError() {
    _clearError();
  }
}
