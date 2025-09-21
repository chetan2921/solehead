import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../widgets/ink_drop_loader.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Infinite scroll logic
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PostProvider>().loadPosts();
    }

    // FAB animation logic
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) {
        setState(() => _showFab = false);
        _fabAnimationController.reverse();
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) {
        setState(() => _showFab = true);
        _fabAnimationController.forward();
      }
    }
  }

  Future<void> _onRefresh() async {
    await context.read<PostProvider>().loadPosts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: ResponsiveContainer(
        child: Consumer<PostProvider>(
          builder: (context, postProvider, child) {
            if (postProvider.posts.isEmpty && postProvider.isLoading) {
              return _buildLoadingState();
            }

            if (postProvider.posts.isEmpty && postProvider.error != null) {
              return _buildErrorState(postProvider);
            }

            if (postProvider.posts.isEmpty) {
              return _buildEmptyState();
            }

            return _buildFeedContent(postProvider);
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to create post
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.8),
      elevation: 0,
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF0A0A0A).withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.only(left: 5, right: 12),
        child: Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
            //     ),
            //     boxShadow: [
            //       BoxShadow(
            //         color: const Color(0xFF00F5FF).withOpacity(0.3),
            //         blurRadius: 10,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: const Icon(
            //     Icons.sports_baseball,
            //     color: Colors.white,
            //     size: 20,
            //   ),
            // ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00F5FF), Color(0xFFFFFFFF)],
              ).createShader(bounds),
              child: const Text(
                'SoleHead',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      // actions: [
      //   Container(
      //     padding: const EdgeInsets.only(top: 20, right: 16),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: const Color(0xFF1A1A1A).withOpacity(0.8),
      //         borderRadius: BorderRadius.circular(12),
      //         border: Border.all(color: const Color(0xFF333333), width: 1),
      //       ),
      //       child: IconButton(
      //         icon: const Icon(
      //           Icons.logout_rounded,
      //           color: Color(0xFF00F5FF),
      //           size: 20,
      //         ),
      //         onPressed: () async {
      //           await context.read<AuthProvider>().logout();
      //           if (mounted) {
      //             Navigator.pushReplacementNamed(context, '/login');
      //           }
      //         },
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkDropLoader(size: 60),
            SizedBox(height: 24),
            Text(
              'Loading fresh kicks...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PostProvider postProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4757).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF4757),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              postProvider.error!,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                ),
              ),
              child: ElevatedButton(
                onPressed: () => postProvider.loadPosts(refresh: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👟', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            Text(
              'No kicks yet!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to share your fire sneakers 🔥',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(PostProvider postProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: const Color(0xFF1A1A1A),
        color: const Color(0xFF00F5FF),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            top: 75,
            bottom: 75,
          ), // Adjusted for 65px nav
          itemCount:
              postProvider.posts.length + (postProvider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= postProvider.posts.length) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: const Center(child: InkDropLoader(size: 40)),
              );
            }

            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: PostCard(post: postProvider.posts[index], index: index),
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final PostModel post;
  final int index;

  const PostCard({super.key, required this.post, this.index = 0});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _likeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Stagger animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ResponsivePadding(
        mobilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tabletPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: GestureDetector(
          onTap: () => _navigateToPostDetail(context),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF333333).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(),
                _buildPostImage(),
                _buildSimplifiedContent(),
                _buildSimplifiedActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPostDetail(BuildContext context) {
    Navigator.pushNamed(context, '/post', arguments: widget.post.id);
  }

  void _navigateToUserProfile(BuildContext context, UserModel? user) {
    if (user == null) return;

    // Don't navigate to own profile
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser?.id == user.id) return;

    Navigator.pushNamed(
      context,
      '/user-profile',
      arguments: {'userId': user.id, 'initialUser': user},
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(context, widget.post.user),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1A1A1A),
                backgroundImage:
                    widget.post.user?.profilePhoto.isNotEmpty == true
                    ? NetworkImage(widget.post.user!.profilePhoto)
                    : null,
                child: widget.post.user?.profilePhoto.isEmpty != false
                    ? Text(
                        widget.post.user?.username
                                .substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          color: Color(0xFF00F5FF),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _navigateToUserProfile(context, widget.post.user),
                      child: Text(
                        widget.post.user?.username ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 6,
                    //     vertical: 2,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF00F5FF).withOpacity(0.2),
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   // child: const Text(
                    //   //   'VERIFIED',
                    //   //   style: TextStyle(
                    //   //     color: Color(0xFF00F5FF),
                    //   //     fontSize: 10,
                    //   //     fontWeight: FontWeight.w700,
                    //   //   ),
                    //   // ),
                    // ),
                  ],
                ),
                const SizedBox(height: 0),
                Text(
                  _formatDate(widget.post.createdAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () => _showPostOptions(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    if (widget.post.mainImage.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 0.85,
          child: widgets.CachedImageWidget(
            imageUrl: widget.post.mainImage,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSimplifiedContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show sneaker brand and name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00F5FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '${widget.post.brandName} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00F5FF),
                    ),
                  ),
                  TextSpan(text: widget.post.sneakerName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildSimplifiedActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ScaleTransition(
            scale: _likeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: _isLiked
                    ? const Color(0xFFFF4757).withOpacity(0.2)
                    : const Color(0xFF2A2A2A).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isLiked
                      ? const Color(0xFFFF4757).withOpacity(0.5)
                      : const Color(0xFF404040),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  widget.post.isLikedBy(
                        context.read<AuthProvider>().user?.id ?? '',
                      )
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      widget.post.isLikedBy(
                        context.read<AuthProvider>().user?.id ?? '',
                      )
                      ? const Color(0xFFFF4757)
                      : Colors.white60,
                  size: 22,
                ),
                onPressed: _toggleLike,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.post.likeCount} ${widget.post.likeCount == 1 ? 'like' : 'likes'}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // View details button
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
          //     ),
          //     borderRadius: BorderRadius.circular(20),
          //     boxShadow: [
          //       BoxShadow(
          //         color: const Color(0xFF00F5FF).withOpacity(0.3),
          //         blurRadius: 10,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: TextButton.icon(
          //     onPressed: () => _navigateToPostDetail(context),
          //     style: TextButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 8,
          //       ),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //     ),
          //     icon: const Icon(
          //       Icons.visibility_rounded,
          //       color: Colors.white,
          //       size: 16,
          //     ),
          //     label: const Text(
          //       'View Details',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w600,
          //         fontSize: 12,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _toggleLike() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;

    print('Toggle like - User logged in: ${authProvider.isLoggedIn}');
    print('Toggle like - Current user: ${currentUser?.id}');
    print('Toggle like - Post ID: ${widget.post.id}');

    if (currentUser == null) {
      print('No current user found, cannot like post');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to like posts'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    // Animate like button
    setState(() {
      _isLiked = !_isLiked;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    final success = await context.read<PostProvider>().toggleLike(
      widget.post.id,
    );

    if (!success && context.mounted) {
      setState(() {
        _isLiked = !_isLiked; // Revert on failure
      });

      final error = context.read<PostProvider>().error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFFF4757),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF00F5FF),
                  size: 20,
                ),
              ),
              title: const Text(
                'Share',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.report_rounded,
                  color: Color(0xFFFF4757),
                  size: 20,
                ),
              ),
              title: const Text(
                'Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
