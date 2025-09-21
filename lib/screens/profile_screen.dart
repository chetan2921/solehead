import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../models/post_model.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<PostProvider>().loadUserPosts(user.id, refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    // No need to navigate manually - AuthWrapper will handle it
    // when authProvider.isLoggedIn changes to false
  }

  void _editProfile() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon!')),
    );
  }

  void _openSettings() {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings feature coming soon!')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _viewFollowers() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      Navigator.pushNamed(
        context,
        '/followers',
        arguments: {
          'userId': user.id,
          'username': user.username,
          'isCurrentUser': true,
        },
      );
    }
  }

  void _viewFollowing() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      Navigator.pushNamed(
        context,
        '/following',
        arguments: {
          'userId': user.id,
          'username': user.username,
          'isCurrentUser': true,
        },
      );
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Modern App Bar with gradient
              SliverAppBar(
                expandedHeight: 330, // Increased from 280
                pinned: false,
                backgroundColor: AppColors.primary,
                elevation: 0,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit Profile'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: ListTile(
                            leading: Icon(Icons.settings_outlined),
                            title: Text('Settings'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout, color: AppColors.error),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _editProfile();
                            break;
                          case 'settings':
                            _openSettings();
                            break;
                          case 'logout':
                            _showLogoutDialog();
                            break;
                        }
                      },
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
                            const SizedBox(height: 20),
                            // Enhanced Profile Photo with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                backgroundImage: user.profilePhoto.isNotEmpty
                                    ? NetworkImage(user.profilePhoto)
                                    : null,
                                child: user.profilePhoto.isEmpty
                                    ? Text(
                                        user.username.isNotEmpty
                                            ? user.username[0].toUpperCase()
                                            : user.email[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Username with verification badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue.shade300,
                                  size: 20,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            const SizedBox(height: 16),

                            // Enhanced Stats with glassmorphism effect
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: ResponsiveBuilder(
                                builder: (context, isMobile, isTablet, isDesktop) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Expanded(
                                      //   child: _buildEnhancedStatColumn(
                                      //     'Posts',
                                      //     user.postCount?.toString() ?? '0',
                                      //     Icons.photo_camera_outlined,
                                      //   ),
                                      // ),
                                      // _buildDivider(),
                                      Expanded(
                                        child: _buildEnhancedStatColumn(
                                          'Sneakers',
                                          user.totalSneakerCount.toString(),
                                          Icons.sports_basketball_outlined,
                                        ),
                                      ),
                                      _buildDivider(),
                                      Expanded(
                                        child: _buildEnhancedStatColumn(
                                          'Followers',
                                          _formatCount(user.followers),
                                          Icons.people_outline,
                                          onTap: () => _viewFollowers(),
                                        ),
                                      ),
                                      _buildDivider(),
                                      Expanded(
                                        child: _buildEnhancedStatColumn(
                                          'Following',
                                          _formatCount(user.following),
                                          Icons.person_add_outlined,
                                          onTap: () => _viewFollowing(),
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

              // Enhanced Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color.fromARGB(255, 255, 255, 255),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                      Tab(icon: Icon(Icons.favorite_outline), text: 'Liked'),
                    ],
                  ),
                ),
              ),

              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildPostsTab(), _buildLikedTab()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnhancedStatColumn(
    String label,
    String count,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: onTap != null
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
            const SizedBox(height: 4),
            Text(
              count,
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
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
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
              final user = context.read<AuthProvider>().user;
              if (user != null) {
                postProvider.loadUserPosts(user.id, refresh: true);
              }
            },
          );
        }

        if (postProvider.userPosts.isEmpty) {
          return _buildEmptyState();
        }

        return ResponsiveBuilder(
          builder: (context, isMobile, isTablet, isDesktop) {
            int crossAxisCount = 2;
            if (isTablet) crossAxisCount = 3;
            if (isDesktop) crossAxisCount = 4;

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                8.0,
                8.0,
                8.0,
                75.0,
              ), // Adjusted for 65px nav
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: postProvider.userPosts.length,
                itemBuilder: (context, index) {
                  final post = postProvider.userPosts[index];
                  return _buildPostCard(post);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedTab() {
    // TODO: Implement liked posts tab
    return const Padding(
      padding: EdgeInsets.only(bottom: 75), // Adjusted for 65px nav
      child: Center(
        child: Text(
          'Liked posts feature coming soon!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 75), // Adjusted for 65px nav
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share your first sneaker collection!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to post detail screen
        Navigator.pushNamed(context, '/post-detail', arguments: post);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                post.mainImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 32,
                    ),
                  );
                },
              ),
              if (post.additionalImages.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.additionalImages.length + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color:
                            context.read<AuthProvider>().user != null &&
                                post.isLikedBy(
                                  context.read<AuthProvider>().user!.id,
                                )
                            ? Colors.red
                            : Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${post.sneakerName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      // height: 60,
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
