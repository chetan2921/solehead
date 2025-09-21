import 'package:flutter/material.dart';
import 'dart:io';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

class PostProvider with ChangeNotifier {
  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  List<PostModel> _followingPosts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePosts = true;

  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;
  List<PostModel> get followingPosts => _followingPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePosts => _hasMorePosts;

  Future<bool> createPost({
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
    _setLoading(true);
    _clearError();

    try {
      final newPost = await PostService.createPost(
        mainImageFile: mainImageFile,
        brandName: brandName,
        sneakerName: sneakerName,
        description: description,
        additionalImageFiles: additionalImageFiles,
        purchaseLink: purchaseLink,
        purchaseAddress: purchaseAddress,
        price: price,
        year: year,
      );

      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _posts.clear();
    }

    if (!_hasMorePosts || _isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final newPosts = await PostService.getAllPosts(
        page: _currentPage,
        limit: 10,
      );

      if (newPosts.length < 10) {
        _hasMorePosts = false;
      }

      if (refresh) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }

      _currentPage++;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFollowingPosts({bool refresh = false}) async {
    if (refresh) {
      _followingPosts.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final posts = await PostService.getFollowingPosts(
        page: refresh ? 1 : (_followingPosts.length ~/ 10) + 1,
        limit: 10,
      );

      if (refresh) {
        _followingPosts = posts;
      } else {
        _followingPosts.addAll(posts);
      }

      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserPosts(String userId, {bool refresh = false}) async {
    if (refresh) {
      _userPosts.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final posts = await PostService.getUserPosts(
        userId,
        page: refresh ? 1 : (_userPosts.length ~/ 10) + 1,
        limit: 10,
      );

      if (refresh) {
        _userPosts = posts;
      } else {
        _userPosts.addAll(posts);
      }

      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleLike(String postId) async {
    print('Attempting to toggle like for post: $postId');
    try {
      // Use the new more efficient method that doesn't fetch the full post
      final likeResult = await PostService.toggleLikeStatus(postId);
      print('Successfully toggled like, result: $likeResult');

      if (likeResult['success'] == true) {
        // Update the post locally with the new like status
        await _updatePostLikeStatus(
          postId,
          likeResult['liked'],
          likeResult['likeCount'],
        );
        _clearError(); // Clear any previous errors on success
        return true;
      } else {
        throw Exception('Like toggle failed');
      }
    } catch (e) {
      print('Error toggling like: $e');
      _setError('Failed to like post: ${_getErrorMessage(e)}');
      return false;
    }
  }

  Future<void> _updatePostLikeStatus(
    String postId,
    bool liked,
    int likeCount,
  ) async {
    // Get current user ID to properly update the likes list
    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null) {
      print('Warning: Could not get current user ID for like update');
      return;
    }

    // Update post in all lists
    _posts = _posts.map((post) {
      if (post.id == postId) {
        return _updatePostLikes(post, currentUserId, liked);
      }
      return post;
    }).toList();

    _userPosts = _userPosts.map((post) {
      if (post.id == postId) {
        return _updatePostLikes(post, currentUserId, liked);
      }
      return post;
    }).toList();

    _followingPosts = _followingPosts.map((post) {
      if (post.id == postId) {
        return _updatePostLikes(post, currentUserId, liked);
      }
      return post;
    }).toList();

    notifyListeners();
  }

  PostModel _updatePostLikes(PostModel post, String currentUserId, bool liked) {
    List<String> updatedLikes = List.from(post.likes);

    if (liked && !updatedLikes.contains(currentUserId)) {
      // Add user to likes list
      updatedLikes.add(currentUserId);
    } else if (!liked && updatedLikes.contains(currentUserId)) {
      // Remove user from likes list
      updatedLikes.remove(currentUserId);
    }

    return post.copyWith(likes: updatedLikes);
  }

  Future<String?> _getCurrentUserId() async {
    try {
      // Try to get from Firebase Auth first
      final firebaseUser = FirebaseService.getCurrentUser();
      if (firebaseUser != null) {
        return firebaseUser.uid;
      }

      // Fallback: get from user profile
      final userProfile = await AuthService.getUserProfile();
      return userProfile.id;
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  Future<bool> updatePost(
    String postId, {
    String? description,
    String? purchaseLink,
    String? purchaseAddress,
    double? price,
    int? year,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPost = await PostService.updatePost(
        postId,
        description: description,
        purchaseLink: purchaseLink,
        purchaseAddress: purchaseAddress,
        price: price,
        year: year,
      );

      _updatePostInLists(updatedPost);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      await PostService.deletePost(postId);

      _posts.removeWhere((post) => post.id == postId);
      _userPosts.removeWhere((post) => post.id == postId);
      _followingPosts.removeWhere((post) => post.id == postId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _updatePostInLists(PostModel updatedPost) {
    _updatePostInList(_posts, updatedPost);
    _updatePostInList(_userPosts, updatedPost);
    _updatePostInList(_followingPosts, updatedPost);
    notifyListeners();
  }

  void _updatePostInList(List<PostModel> posts, PostModel updatedPost) {
    final index = posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      posts[index] = updatedPost;
    }
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
    return error.toString().replaceAll('Exception: ', '');
  }

  void clearError() {
    _clearError();
  }
}
