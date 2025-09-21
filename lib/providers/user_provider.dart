import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  UserModel? _selectedUser;
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<UserModel> get followers => _followers;
  List<UserModel> get following => _following;
  UserModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllUsers() async {
    _setLoading(true);
    _clearError();

    try {
      _users = await UserService.getAllUsers();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _users = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _users = await UserService.searchUsers(query);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadUserByUsername(String username) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedUser = await UserService.getUserByUsername(username);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> followUser(String userId) async {
    _clearError();

    try {
      await UserService.followUser(userId);

      // Update selected user if it's the one being followed
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser!.copyWith(
          followers: _selectedUser!.followers + 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    _clearError();

    try {
      await UserService.unfollowUser(userId);

      // Update selected user if it's the one being unfollowed
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser!.copyWith(
          followers: _selectedUser!.followers - 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  Future<void> loadUserFollowers(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _followers = await UserService.getUserFollowers(userId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserFollowing(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _following = await UserService.getUserFollowing(userId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  void setSelectedUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  Future<bool> loadUserProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedUser = await UserService.getUserProfile(userId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      return await UserService.isFollowing(currentUserId, targetUserId);
    } catch (e) {
      return false;
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
