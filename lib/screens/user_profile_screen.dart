import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final UserModel? initialUser; // Optional: if we already have user data

  const UserProfileScreen({super.key, required this.userId, this.initialUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user profile and posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userProvider = context.read<UserProvider>();
    final postProvider = context.read<PostProvider>();

    // Load user profile if not provided
    if (widget.initialUser == null) {
      await userProvider.loadUserProfile(widget.userId);
    } else {
      userProvider.setSelectedUser(widget.initialUser!);
    }

    // Load user posts
    await postProvider.loadUserPosts(widget.userId, refresh: true);

    // Check if current user is following this user
    await _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user != null) {
      try {
        _isFollowing = await userProvider.isFollowing(
          authProvider.user!.id,
          widget.userId,
        );
        if (mounted) setState(() {});
      } catch (e) {
        // Handle error silently or show a message
      }
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user == null) return;

    setState(() {
      _isFollowLoading = true;
    });

    try {
      bool success;
      if (_isFollowing) {
        success = await userProvider.unfollowUser(widget.userId);
      } else {
        success = await userProvider.followUser(widget.userId);
      }

      if (success) {
        setState(() {
          _isFollowing = !_isFollowing;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFollowing ? 'Following user' : 'Unfollowed user',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isFollowing ? 'unfollow' : 'follow'} user',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isFollowLoading = false;
      });
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.selectedUser;
          final isLoading = userProvider.isLoading;
          final error = userProvider.error;

          if (isLoading && user == null) {
            return const widgets.LoadingWidget(message: 'Loading profile...');
          }

          if (error != null && user == null) {
            return widgets.ErrorWidget(
              message: error,
              onRetry: () => _loadUserData(),
            );
          }

          if (user == null) {
            return const widgets.ErrorWidget(message: 'User not found');
          }

          return CustomScrollView(
            slivers: [
              // Enhanced App Bar with back button
              SliverAppBar(
                expandedHeight: 320, // Increased from 280
                pinned: true,
                backgroundColor: AppColors.primary,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showMoreOptions(user),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          Color(0xFF8E24AA),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: ResponsivePadding(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Profile Photo with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: user.profilePhoto.isNotEmpty
                                    ? NetworkImage(user.profilePhoto)
                                    : null,
                                child: user.profilePhoto.isEmpty
                                    ? Text(
                                        user.username
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Username
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),

                            // Follow Button
                            const SizedBox(height: 16),
                            _buildFollowButton(),

                            // Stats Row
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: ResponsiveBuilder(
                                builder:
                                    (context, isMobile, isTablet, isDesktop) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: _buildStatColumn(
                                              'Posts',
                                              user.postCount?.toString() ?? '0',
                                              Icons.photo_camera_outlined,
                                            ),
                                          ),
                                          _buildDivider(),
                                          Expanded(
                                            child: _buildStatColumn(
                                              'Sneakers',
                                              user.totalSneakerCount.toString(),
                                              Icons.sports_basketball_outlined,
                                            ),
                                          ),
                                          _buildDivider(),
                                          Expanded(
                                            child: _buildStatColumn(
                                              'Followers',
                                              _formatCount(user.followers),
                                              Icons.people_outline,
                                              onTap: () => _viewFollowers(user),
                                            ),
                                          ),
                                          _buildDivider(),
                                          Expanded(
                                            child: _buildStatColumn(
                                              'Following',
                                              _formatCount(user.following),
                                              Icons.person_add_outlined,
                                              onTap: () => _viewFollowing(user),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                      Tab(icon: Icon(Icons.info_outline), text: 'About'),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildPostsTab(), _buildAboutTab(user)],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowButton() {
    final authUser = context.read<AuthProvider>().user;

    // Don't show follow button for own profile
    if (authUser?.id == widget.userId) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isFollowLoading ? null : _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing
                ? Colors.white.withOpacity(0.2)
                : Colors.white,
            foregroundColor: _isFollowing ? Colors.white : AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
          child: _isFollowLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isFollowing ? Icons.person_remove : Icons.person_add,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap != null
              ? Colors.white.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 35,
      width: 1,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  Widget _buildPostsTab() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        if (postProvider.userPosts.isEmpty && postProvider.isLoading) {
          return const widgets.LoadingWidget(message: 'Loading posts...');
        }

        if (postProvider.userPosts.isEmpty && postProvider.error != null) {
          return widgets.ErrorWidget(
            message: postProvider.error!,
            onRetry: () {
              postProvider.loadUserPosts(widget.userId, refresh: true);
            },
          );
        }

        if (postProvider.userPosts.isEmpty) {
          return const widgets.EmptyStateWidget(
            title: 'No posts yet',
            message: 'This user hasn\'t shared any sneakers yet.',
            icon: Icons.photo_camera_outlined,
          );
        }

        return ResponsivePadding(
          child: ResponsiveColumns(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 4,
            children: postProvider.userPosts
                .map((post) => PostGridItem(post: post))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(UserModel user) {
    return ResponsivePadding(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'User Information',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Username', user.username),
                    _buildInfoRow('Email', user.email),
                    _buildInfoRow(
                      'Total Sneakers',
                      user.totalSneakerCount.toString(),
                    ),
                    _buildInfoRow('Posts', user.postCount?.toString() ?? '0'),
                    _buildInfoRow('Followers', _formatCount(user.followers)),
                    _buildInfoRow('Following', _formatCount(user.following)),
                    if (user.createdAt != null)
                      _buildInfoRow(
                        'Member Since',
                        '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Activity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppColors.secondary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Activity Overview',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActivityCard(
                            'Posts',
                            user.postCount?.toString() ?? '0',
                            Icons.photo_camera_outlined,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActivityCard(
                            'Sneakers',
                            user.totalSneakerCount.toString(),
                            Icons.sports_basketball_outlined,
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActivityCard(
                            'Followers',
                            _formatCount(user.followers),
                            Icons.people_outline,
                            const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActivityCard(
                            'Following',
                            _formatCount(user.following),
                            Icons.person_add_outlined,
                            const Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text(
                'Block User',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showBlockUserDialog(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.error),
              title: const Text(
                'Report User',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showReportUserDialog(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Block feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showReportUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Text('Are you sure you want to report ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement report functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _viewFollowers(UserModel user) {
    Navigator.pushNamed(
      context,
      '/followers',
      arguments: {
        'userId': user.id,
        'username': user.username,
        'isCurrentUser': false,
      },
    );
  }

  void _viewFollowing(UserModel user) {
    Navigator.pushNamed(
      context,
      '/following',
      arguments: {
        'userId': user.id,
        'username': user.username,
        'isCurrentUser': false,
      },
    );
  }
}

class PostGridItem extends StatelessWidget {
  final PostModel post;

  const PostGridItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _viewPost(context),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widgets.CachedImageWidget(
                imageUrl: post.mainImage,
                fit: BoxFit.cover,
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

              // Post info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.description.length > 30
                          ? '${post.description.substring(0, 30)}...'
                          : post.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              post.likeCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.comment,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '0', // TODO: Add comment count to PostModel
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPost(BuildContext context) {
    // Navigate to post details screen
    Navigator.pushNamed(context, '/post', arguments: post.id);
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
