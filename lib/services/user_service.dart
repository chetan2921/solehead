import '../models/user_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';

class UserService {
  // Get user by username
  static Future<UserModel> getUserByUsername(String username) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserByUsername(username),
      );
      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Follow a user
  static Future<void> followUser(String userId) async {
    try {
      await ApiService.post(
        ApiEndpoints.followUser(userId),
        {},
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Unfollow a user
  static Future<void> unfollowUser(String userId) async {
    try {
      await ApiService.post(
        ApiEndpoints.unfollowUser(userId),
        {},
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get user followers
  static Future<List<UserModel>> getUserFollowers(String userId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserFollowers(userId),
      );
      return (response['followers'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get user following
  static Future<List<UserModel>> getUserFollowing(String userId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserFollowing(userId),
      );
      return (response['following'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search users
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await ApiService.get(
        '${ApiEndpoints.listUsers}?search=$query',
      );
      return (response['users'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get all users (for development)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await ApiService.get(ApiEndpoints.listUsers);
      return (response['users'] as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile by ID
  static Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserProfile(userId),
      );
      return UserModel.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Check if current user is following target user
  static Future<bool> isFollowing(
    String currentUserId,
    String targetUserId,
  ) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.isFollowing(currentUserId, targetUserId),
      );
      return response['isFollowing'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
