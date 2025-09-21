import 'dart:io';
import '../models/post_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';

class PostService {
  // Create post
  static Future<PostModel> createPost({
    required File mainImageFile,
    required String brandName,
    required String sneakerName,
    required String description,
    List<File>? additionalImageFiles,
    String? purchaseLink,
    String? purchaseAddress,
    double? price,
    int? year,
  }) async {
    try {
      final additionalFields = <String, dynamic>{
        'brandName': brandName,
        'sneakerName': sneakerName,
        'description': description,
      };

      if (purchaseLink != null) additionalFields['purchaseLink'] = purchaseLink;
      if (purchaseAddress != null) {
        additionalFields['purchaseAddress'] = purchaseAddress;
      }
      if (price != null) additionalFields['price'] = price.toString();
      if (year != null) additionalFields['year'] = year.toString();

      final response = await ApiService.uploadFile(
        ApiEndpoints.createPost,
        mainImageFile,
        additionalFields: additionalFields,
        requireAuth: true,
        fieldName: 'mainImage',
      );

      return PostModel.fromJson(response['post']);
    } catch (e) {
      rethrow;
    }
  }

  // Get all posts (feed)
  static Future<List<PostModel>> getAllPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getAllPosts,
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );

      return (response['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get following posts
  static Future<List<PostModel>> getFollowingPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getFollowingPosts,
        requireAuth: true,
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );

      return (response['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single post
  static Future<PostModel> getPost(String postId) async {
    try {
      final response = await ApiService.get(ApiEndpoints.getPost(postId));
      return PostModel.fromJson(response['post']);
    } catch (e) {
      rethrow;
    }
  }

  // Update post
  static Future<PostModel> updatePost(
    String postId, {
    String? description,
    String? purchaseLink,
    String? purchaseAddress,
    double? price,
    int? year,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (description != null) data['description'] = description;
      if (purchaseLink != null) data['purchaseLink'] = purchaseLink;
      if (purchaseAddress != null) data['purchaseAddress'] = purchaseAddress;
      if (price != null) data['price'] = price;
      if (year != null) data['year'] = year;

      final response = await ApiService.put(
        ApiEndpoints.updatePost(postId),
        data,
        requireAuth: true,
      );

      return PostModel.fromJson(response['post']);
    } catch (e) {
      rethrow;
    }
  }

  // Delete post
  static Future<void> deletePost(String postId) async {
    try {
      await ApiService.delete(
        ApiEndpoints.deletePost(postId),
        requireAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Like/Unlike post
  static Future<Map<String, dynamic>> toggleLikeStatus(String postId) async {
    print('PostService: Toggling like for post $postId');
    try {
      final response = await ApiService.post(
        ApiEndpoints.likePost(postId),
        {},
        requireAuth: true,
      );

      print('PostService: Like toggle response received: $response');

      // The backend returns: {message, likeCount, liked}
      if (response['message'] != null &&
          response['likeCount'] != null &&
          response['liked'] != null) {
        return {
          'success': true,
          'liked': response['liked'],
          'likeCount': response['likeCount'],
          'message': response['message'],
        };
      } else {
        throw Exception('Invalid response from server: ${response.toString()}');
      }
    } catch (e) {
      print('PostService: Error in toggleLike: $e');
      rethrow;
    }
  }

  // Legacy method for backward compatibility - will be updated
  static Future<PostModel> toggleLike(String postId) async {
    // This method is deprecated - use toggleLikeStatus instead
    // For now, we'll fetch the updated post after the like toggle
    try {
      await toggleLikeStatus(postId);
      return await getPost(postId);
    } catch (e) {
      print('PostService: Error in legacy toggleLike: $e');
      rethrow;
    }
  } // Get user's posts

  static Future<List<PostModel>> getUserPosts(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get(
        ApiEndpoints.getUserPosts(userId),
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
      );

      return (response['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
