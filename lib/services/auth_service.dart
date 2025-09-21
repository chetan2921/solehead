import 'dart:io';
import '../models/user_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';
import 'firebase_service.dart';

class AuthService {
  // Register user
  static Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    print('Starting registration for email: $email');

    // Check if Firebase is available
    if (!FirebaseService.isFirebaseAvailable()) {
      print('Firebase not available, attempting direct backend registration');
      try {
        final response = await ApiService.post(ApiEndpoints.register, {
          'username': username,
          'email': email,
          'password': password,
        }, requireAuth: false);

        return UserModel.fromJson(response['user']);
      } catch (e) {
        print('Direct backend registration failed: $e');
        throw Exception('Registration failed: ${e.toString()}');
      }
    }

    // Firebase is available, use Firebase + backend flow
    try {
      print('Creating Firebase user');
      // Create Firebase user first
      final credential = await FirebaseService.registerWithEmailPassword(
        email,
        password,
      );

      if (credential?.user == null) {
        throw Exception('Failed to create Firebase user');
      }

      print('Firebase user created, getting ID token');
      // Get Firebase ID token
      final idToken = await credential!.user!.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      print('Registering with backend using Firebase token');
      // Register with backend using Firebase token
      final response = await ApiService.post(ApiEndpoints.register, {
        'idToken': idToken,
        'username': username,
        'email': email,
      }, requireAuth: false);

      return UserModel.fromJson(response['user']);
    } catch (e) {
      print('Firebase registration failed: $e');

      // Clean up Firebase user if created but backend failed
      try {
        final user = FirebaseService.getCurrentUser();
        if (user != null) {
          await user.delete();
          print('Cleaned up Firebase user after backend failure');
        }
      } catch (cleanupError) {
        print('Firebase cleanup error: $cleanupError');
      }

      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Mock register for development
  static Future<UserModel> mockRegister(String username, String email) async {
    try {
      final response = await ApiService.post(ApiEndpoints.mockRegister, {
        'username': username,
        'email': email,
      }, requireAuth: false);

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    print('Starting login for email: $email');

    // Check if Firebase is available
    if (!FirebaseService.isFirebaseAvailable()) {
      print('Firebase not available, attempting direct backend login');
      try {
        final response = await ApiService.post(ApiEndpoints.login, {
          'email': email,
          'password': password,
        }, requireAuth: false);

        return UserModel.fromJson(response['user']);
      } catch (e) {
        print('Direct backend login failed: $e');
        throw Exception('Login failed: ${e.toString()}');
      }
    }

    // Firebase is available, use Firebase + backend flow
    try {
      print('Attempting Firebase authentication');
      // Sign in with Firebase first
      final credential = await FirebaseService.signInWithEmailPassword(
        email,
        password,
      );

      if (credential?.user == null) {
        throw Exception('Invalid email or password');
      }

      print('Firebase authentication successful, getting ID token');
      // Get Firebase ID token
      final idToken = await credential!.user!.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to get authentication token');
      }

      print('Logging in with backend using Firebase token');
      // Login with backend using Firebase token
      final response = await ApiService.post(ApiEndpoints.login, {
        'idToken': idToken,
      }, requireAuth: false);

      return UserModel.fromJson(response['user']);
    } catch (e) {
      print('Firebase login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Mock login for development
  static Future<UserModel> mockLogin(String username) async {
    try {
      final response = await ApiService.post(ApiEndpoints.mockLogin, {
        'username': username,
      }, requireAuth: false);

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  static Future<UserModel> getUserProfile() async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.profile,
        requireAuth: true,
      );

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<UserModel> updateProfile({
    String? username,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      final response = await ApiService.put(
        ApiEndpoints.profile,
        data,
        requireAuth: true,
      );

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile photo
  static Future<UserModel> uploadProfilePhoto(String filePath) async {
    try {
      final response = await ApiService.uploadFile(
        ApiEndpoints.uploadProfilePhoto,
        File(filePath),
        requireAuth: true,
        fieldName: 'profilePhoto',
      );

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    await FirebaseService.signOut();
  }

  // Create test user for development
  static Future<UserModel> createTestUser({
    required String username,
    required String email,
  }) async {
    try {
      final response = await ApiService.post(ApiEndpoints.createTestUser, {
        'username': username,
        'email': email,
      }, requireAuth: false);

      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }
}
