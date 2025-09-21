import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if Firebase is available and initialized
  static bool isFirebaseAvailable() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      print('Firebase availability check failed: $e');
      return false;
    }
  }

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get Firebase ID Token
  static Future<String?> getIdToken() async {
    try {
      final user = getCurrentUser();
      print('Firebase Service: Current user: ${user?.uid}');
      if (user != null) {
        final token = await user.getIdToken();
        print('Firebase Service: Token retrieved, length: ${token?.length}');
        // Ensure we return a string, not a Map or other type
        if (token is String) {
          return token;
        }
        print(
          'Warning: getIdToken returned non-string type: ${token.runtimeType}',
        );
        return null;
      }
      print('Firebase Service: No current user found');
      return null;
    } catch (e) {
      print('Error getting Firebase ID token: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('Firebase: Attempting sign in with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase: Sign in successful for user: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email address');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      print('Firebase: Unexpected error during sign in: $e');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  // Register with email and password
  static Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('Firebase: Attempting registration with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
        'Firebase: Registration successful for user: ${credential.user?.uid}',
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw Exception(
            'Password is too weak. Please use at least 6 characters',
          );
        case 'email-already-in-use':
          throw Exception('An account already exists with this email address');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print('Firebase: Unexpected error during registration: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state changes stream
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = getCurrentUser();
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  // Verify email
  static Future<void> sendEmailVerification() async {
    final user = getCurrentUser();
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check if email is verified
  static bool get isEmailVerified {
    final user = getCurrentUser();
    return user?.emailVerified ?? false;
  }

  // Reload user to get updated info
  static Future<void> reloadUser() async {
    final user = getCurrentUser();
    if (user != null) {
      await user.reload();
    }
  }
}
