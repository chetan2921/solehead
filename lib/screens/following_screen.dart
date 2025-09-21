import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../models/user_model.dart';
import '../utils/constants.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;
  final String username;
  final bool isCurrentUser;

  const FollowingScreen({
    super.key,
    required this.userId,
    required this.username,
    this.isCurrentUser = false,
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserFollowing(widget.userId);
    });
  }

  Future<void> _refreshFollowing() async {
    await context.read<UserProvider>().loadUserFollowing(widget.userId);
  }

  void _navigateToUserProfile(UserModel user) {
    if (user.id == widget.userId) {
      Navigator.pop(context); // Go back if it's the same user
      return;
    }

    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null && user.id == currentUser.id) {
      Navigator.pop(context); // Go back to profile if it's current user
      return;
    }

    Navigator.pushNamed(
      context,
      '/user-profile',
      arguments: {'userId': user.id, 'initialUser': user},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isCurrentUser
              ? 'You\'re Following'
              : '${widget.username} is Following',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.following.isEmpty) {
            return const Center(
              child: widgets.LoadingWidget(message: 'Loading following...'),
            );
          }

          if (userProvider.error != null) {
            return Center(
              child: widgets.ErrorWidget(
                message: userProvider.error!,
                onRetry: _refreshFollowing,
              ),
            );
          }

          if (userProvider.following.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshFollowing,
            color: AppColors.primary,
            child: ResponsivePadding(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: userProvider.following.length,
                itemBuilder: (context, index) {
                  final followingUser = userProvider.following[index];
                  return _buildUserCard(followingUser);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            widget.isCurrentUser
                ? 'You\'re not following anyone yet'
                : '${widget.username} isn\'t following anyone yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isCurrentUser
                ? 'Discover amazing sneakerheads to follow!'
                : 'Maybe they\'ll find some great sneaker enthusiasts soon!',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final currentUser = context.read<AuthProvider>().user;
    final isCurrentUser = currentUser?.id == user.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () => _navigateToUserProfile(user),
          child: Hero(
            tag: 'user_avatar_${user.id}',
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user.profilePhoto.isNotEmpty
                  ? NetworkImage(user.profilePhoto)
                  : null,
              child: user.profilePhoto.isEmpty
                  ? Text(
                      user.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => _navigateToUserProfile(user),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  user.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentUser)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        subtitle: GestureDetector(
          onTap: () => _navigateToUserProfile(user),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.followers} followers',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.postCount ?? 0} posts',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: isCurrentUser ? null : _buildFollowButton(user),
      ),
    );
  }

  Widget _buildFollowButton(UserModel user) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return FutureBuilder<bool>(
          future: _checkIfFollowing(user.id),
          builder: (context, snapshot) {
            final isFollowing = snapshot.data ?? false;

            return SizedBox(
              width: 80,
              height: 32,
              child: ElevatedButton(
                onPressed: () => _toggleFollow(user.id, isFollowing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey.shade200
                      : AppColors.primary,
                  foregroundColor: isFollowing
                      ? Colors.grey.shade700
                      : Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _checkIfFollowing(String userId) async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) return false;

    return await context.read<UserProvider>().isFollowing(
      currentUser.id,
      userId,
    );
  }

  Future<void> _toggleFollow(String userId, bool isCurrentlyFollowing) async {
    final userProvider = context.read<UserProvider>();

    bool success;
    if (isCurrentlyFollowing) {
      success = await userProvider.unfollowUser(userId);
    } else {
      success = await userProvider.followUser(userId);
    }

    if (success) {
      // Refresh the following list to get updated data
      await _refreshFollowing();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFollowing
                  ? 'Unfollowed successfully'
                  : 'Following successfully',
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isCurrentlyFollowing ? 'unfollow' : 'follow'} user',
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
