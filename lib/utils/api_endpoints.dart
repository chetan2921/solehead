import 'constants.dart';

class ApiEndpoints {
  // Authentication
  static const String register =
      '${ApiConstants.baseUrl}${ApiConstants.auth}/register';
  static const String login =
      '${ApiConstants.baseUrl}${ApiConstants.auth}/login';
  static const String profile =
      '${ApiConstants.baseUrl}${ApiConstants.auth}/profile';
  static const String uploadProfilePhoto =
      '${ApiConstants.baseUrl}${ApiConstants.auth}/profile/photo';

  // Users
  static String getUserByUsername(String username) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$username';
  static String followUser(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/follow';
  static String unfollowUser(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/unfollow';
  static String getUserFollowers(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/followers';
  static String getUserFollowing(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/following';
  static String getUserProfile(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/profile';
  static String isFollowing(String currentUserId, String targetUserId) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/$currentUserId/following/$targetUserId';
  static String searchUsers(String query) =>
      '${ApiConstants.baseUrl}${ApiConstants.users}/search?q=$query';

  // Posts
  static const String createPost =
      '${ApiConstants.baseUrl}${ApiConstants.posts}';
  static const String getAllPosts =
      '${ApiConstants.baseUrl}${ApiConstants.posts}';
  static const String getFollowingPosts =
      '${ApiConstants.baseUrl}${ApiConstants.posts}/following';
  static String getPost(String postId) =>
      '${ApiConstants.baseUrl}${ApiConstants.posts}/$postId';
  static String updatePost(String postId) =>
      '${ApiConstants.baseUrl}${ApiConstants.posts}/$postId';
  static String deletePost(String postId) =>
      '${ApiConstants.baseUrl}${ApiConstants.posts}/$postId';
  static String likePost(String postId) =>
      '${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/like';
  static String getUserPosts(String userId) =>
      '${ApiConstants.baseUrl}${ApiConstants.posts}/user/$userId';

  // Sneakers
  static const String getAllSneakers =
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}';
  static const String getTopSneakers =
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}/top';
  static String getSneaker(String sneakerId) =>
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}/$sneakerId';
  static String rateSneaker(String sneakerId) =>
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}/$sneakerId/rate';
  static String searchSneakers(String query) =>
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}/search/$query';
  static String getSneakersByBrand(String brand) =>
      '${ApiConstants.baseUrl}${ApiConstants.sneakers}/brand/$brand';

  // Development (remove in production)
  static const String createTestUser =
      '${ApiConstants.baseUrl}${ApiConstants.dev}/create-user';
  static const String listUsers =
      '${ApiConstants.baseUrl}${ApiConstants.dev}/users';
  static const String mockLogin =
      '${ApiConstants.baseUrl}${ApiConstants.dev}/mock-login';
  static const String mockRegister =
      '${ApiConstants.baseUrl}${ApiConstants.dev}/mock-register';
}
