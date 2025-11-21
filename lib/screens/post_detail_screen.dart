import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  late AnimationController _likeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _likeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentImageIndex = 0;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    // Load posts if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = context.read<PostProvider>();
      if (postProvider.posts.isEmpty) {
        postProvider.loadPosts();
      }
    });

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _slideAnimationController.forward();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _likeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Hide/show app bar based on scroll
    if (_scrollController.offset > 200 && _showAppBar) {
      setState(() => _showAppBar = false);
    } else if (_scrollController.offset <= 200 && !_showAppBar) {
      setState(() => _showAppBar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          PostModel? post;
          try {
            post = postProvider.posts.firstWhere((p) => p.id == widget.postId);
          } catch (e) {
            post = null;
          }

          if (post == null && postProvider.isLoading) {
            return _buildLoadingState();
          }

          if (post == null && postProvider.error != null) {
            return _buildErrorState(postProvider);
          }

          if (post == null) {
            return _buildNotFoundState();
          }

          return _buildPostContent(post);
        },
      ),
      // floatingActionButton: ScaleTransition(
      //   scale: _fabAnimation,
      //   child: _buildFloatingActionButtons(),
      // ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: _showAppBar
          ? const Color.fromARGB(0, 10, 10, 10).withOpacity(0.9)
          : Colors.transparent,
      elevation: 0,
      toolbarHeight: 40,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 5),
        // decoration: BoxDecoration(
        //   color: const Color(0xFF1A1A1A).withOpacity(0.8),
        //   borderRadius: BorderRadius.circular(12),
        //   border: Border.all(color: const Color(0xFF333333), width: 1),
        // ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text(
          'Post Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 5),
          // decoration: BoxDecoration(
          //   color: const Color(0xFF1A1A1A).withOpacity(0.8),
          //   borderRadius: BorderRadius.circular(12),
          //   border: Border.all(color: const Color(0xFF333333), width: 1),
          // ),
          child: IconButton(
            onPressed: () => _sharePost(),
            icon: const Icon(
              Icons.share_rounded,
              color: Color(0xFF00F5FF),
              size: 20,
            ),
          ),
        ),
      ],
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
            CircularProgressIndicator(color: Color(0xFF00F5FF), strokeWidth: 3),
            SizedBox(height: 24),
            Text(
              'Loading post details...',
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
              'Failed to load post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Something went wrong while loading the post details',
              style: TextStyle(color: Colors.white60, fontSize: 14),
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

  Widget _buildNotFoundState() {
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
            Text('👻', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            Text(
              'Post Not Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This post might have been deleted or moved',
              style: TextStyle(color: Colors.white60, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(PostModel post) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 100,
                    ), // Increased from 50 for proper spacing
                    _buildPostHeader(post),
                    _buildPostImages(post),
                    // _buildPostActions(post),
                    _buildPostContentInfo(post),
                    _buildSneakerDetails(post),
                    // _buildCommentsSection(post),
                    const SizedBox(height: 100), // Account for comment input
                  ],
                ),
              ),
            ),
          ),
          // _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader(PostModel post) {
    return ResponsivePadding(
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
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
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Container(
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
                  radius: 24,
                  backgroundColor: const Color(0xFF1A1A1A),
                  backgroundImage: post.user?.profilePhoto.isNotEmpty == true
                      ? NetworkImage(post.user!.profilePhoto)
                      : null,
                  child: post.user?.profilePhoto.isEmpty != false
                      ? Text(
                          post.user?.username.substring(0, 1).toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            color: Color(0xFF00F5FF),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.user?.username ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 8,
                        //     vertical: 2,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF00F5FF).withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: const Text(
                        //     'VERIFIED',
                        //     style: TextStyle(
                        //       color: Color(0xFF00F5FF),
                        //       fontSize: 10,
                        //       fontWeight: FontWeight.w700,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _showPostOptions(post),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostImages(PostModel post) {
    final allImages = [post.mainImage, ...post.additionalImages];

    return Container(
      height: 480,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _pageController,
              itemCount: allImages.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
                // Add haptic feedback when switching images
                if (allImages.length > 1) {
                  HapticFeedback.selectionClick();
                }
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    // Add parallax effect for smooth transitions
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: widgets.CachedImageWidget(
                          imageUrl: allImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (allImages.length > 1) ...[
            // Image indicator dots
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  allImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? const Color(0xFF00F5FF)
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Image counter with enhanced styling
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF00F5FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${allImages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Left/Right navigation hints for mobile
            if (allImages.length > 1) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentImageIndex > 0 ? 0.6 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentImageIndex < allImages.length - 1
                        ? 0.6
                        : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Widget _buildPostActions(PostModel post) {
  //   final isLiked = post.likes.isNotEmpty; // Check if user liked (simplified)

  //   return ResponsivePadding(
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF1A1A1A).withOpacity(0.6),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: const Color(0xFF333333).withOpacity(0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           ScaleTransition(
  //             scale: _likeAnimation,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: isLiked
  //                     ? const Color(0xFFFF4757).withOpacity(0.2)
  //                     : Colors.transparent,
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: IconButton(
  //                 onPressed: () => _toggleLike(post),
  //                 icon: Icon(
  //                   isLiked
  //                       ? Icons.favorite_rounded
  //                       : Icons.favorite_border_rounded,
  //                   color: isLiked ? const Color(0xFFFF4757) : Colors.white70,
  //                   size: 26,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           // IconButton(
  //           //   onPressed: () => _focusCommentInput(),
  //           //   icon: const Icon(
  //           //     Icons.comment_rounded,
  //           //     color: Colors.white70,
  //           //     size: 24,
  //           //   ),
  //           // ),
  //           // const SizedBox(width: 8),
  //           // IconButton(
  //           //   onPressed: () => _sharePost(),
  //           //   icon: const Icon(
  //           //     Icons.share_rounded,
  //           //     color: Colors.white70,
  //           //     size: 24,
  //           //   ),
  //           // ),
  //           const Spacer(),
  //           Container(
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF2A2A2A).withOpacity(0.5),
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: IconButton(
  //               onPressed: () => _savePost(post),
  //               icon: const Icon(
  //                 Icons.bookmark_border_rounded,
  //                 color: Color(0xFF00F5FF),
  //                 size: 24,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPostContentInfo(PostModel post) {
    return ResponsivePadding(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
        padding: const EdgeInsets.only(
          left: 12,
          right: 20,
          top: 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF333333).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 6,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A).withOpacity(0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'} ❤️',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (post.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: 'Description:   ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00F5FF),
                      ),
                    ),
                    TextSpan(text: post.description),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSneakerDetails(PostModel post) {
    return ResponsivePadding(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F5FF).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sneaker Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Brand', post.brandName),
              _buildDetailRow('Name', post.sneakerName),
              if (post.price != null)
                _buildDetailRow('Price', '\$${post.price!.toStringAsFixed(2)}'),
              if (post.year != null)
                _buildDetailRow('Year', post.year.toString()),
              if (post.purchaseAddress != null)
                _buildDetailRow('Purchase Address', post.purchaseAddress!),
              if (post.purchaseLink != null)
                _buildDetailRow('Purchase Link', 'Available'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF404040).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label : ',
              style: const TextStyle(
                color: Color(0xFF00F5FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCommentsSection(PostModel post) {
  //   return ResponsivePadding(
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF1A1A1A).withOpacity(0.8),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: const Color(0xFF333333).withOpacity(0.5),
  //           width: 1,
  //         ),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF2A2A2A).withOpacity(0.8),
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: const Icon(
  //                   Icons.comment_rounded,
  //                   color: Color(0xFF00F5FF),
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               const Text(
  //                 'Comments',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF2A2A2A).withOpacity(0.3),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(
  //                 color: const Color(0xFF404040).withOpacity(0.3),
  //                 width: 1,
  //               ),
  //             ),
  //             child: TextButton.icon(
  //               onPressed: () => _loadComments(post),
  //               icon: const Icon(
  //                 Icons.visibility_outlined,
  //                 color: Color(0xFF00F5FF),
  //                 size: 18,
  //               ),
  //               label: const Text(
  //                 'View all comments',
  //                 style: TextStyle(
  //                   color: Color(0xFF00F5FF),
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCommentInput() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF1A1A1A).withOpacity(0.95),
  //       border: Border(
  //         top: BorderSide(
  //           color: const Color(0xFF333333).withOpacity(0.5),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           Consumer<AuthProvider>(
  //             builder: (context, authProvider, child) {
  //               final user = authProvider.user;
  //               return Container(
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   gradient: const LinearGradient(
  //                     colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  //                   ),
  //                 ),
  //                 padding: const EdgeInsets.all(2),
  //                 child: CircleAvatar(
  //                   radius: 18,
  //                   backgroundColor: const Color(0xFF1A1A1A),
  //                   backgroundImage: user?.profilePhoto.isNotEmpty == true
  //                       ? NetworkImage(user!.profilePhoto)
  //                       : null,
  //                   child: user?.profilePhoto.isEmpty != false
  //                       ? Text(
  //                           user?.username.substring(0, 1).toUpperCase() ?? 'U',
  //                           style: const TextStyle(
  //                             color: Color(0xFF00F5FF),
  //                             fontWeight: FontWeight.w700,
  //                             fontSize: 14,
  //                           ),
  //                         )
  //                       : null,
  //                 ),
  //               );
  //             },
  //           ),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF2A2A2A).withOpacity(0.8),
  //                 borderRadius: BorderRadius.circular(25),
  //                 border: Border.all(
  //                   color: _isCommentFocused
  //                       ? const Color(0xFF00F5FF).withOpacity(0.5)
  //                       : const Color(0xFF404040).withOpacity(0.3),
  //                   width: 1,
  //                 ),
  //               ),
  //               child: TextField(
  //                 controller: _commentController,
  //                 onTap: () => setState(() => _isCommentFocused = true),
  //                 onTapOutside: (_) =>
  //                     setState(() => _isCommentFocused = false),
  //                 style: const TextStyle(color: Colors.white, fontSize: 16),
  //                 decoration: InputDecoration(
  //                   hintText: 'Add a comment...',
  //                   hintStyle: TextStyle(
  //                     color: Colors.white.withOpacity(0.5),
  //                     fontSize: 16,
  //                   ),
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(
  //                     horizontal: 20,
  //                     vertical: 12,
  //                   ),
  //                 ),
  //                 maxLines: null,
  //                 textInputAction: TextInputAction.send,
  //                 onSubmitted: (_) => _submitComment(),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: const LinearGradient(
  //                 colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  //               ),
  //               borderRadius: BorderRadius.circular(20),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: const Color(0xFF00F5FF).withOpacity(0.3),
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 4),
  //                 ),
  //               ],
  //             ),
  //             child: IconButton(
  //               onPressed: _submitComment,
  //               icon: const Icon(
  //                 Icons.send_rounded,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFloatingActionButtons() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       //    Container(
  //       //      decoration: BoxDecoration(
  //       //        gradient: const LinearGradient(
  //       //          colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  //       //        ),
  //       //        borderRadius: BorderRadius.circular(16),
  //       //        boxShadow: [
  //       //          BoxShadow(
  //       //            color: const Color(0xFF00F5FF).withOpacity(0.3),
  //       //         blurRadius: 15,
  //       //            offset: const Offset(0, 6),
  //       //          ),
  //       //        ],
  //       //     ),
  //       //      child: FloatingActionButton(
  //       //       heroTag: "share",
  //       //       onPressed: _sharePost,
  //       //        backgroundColor: Colors.transparent,
  //       //        elevation: 0,
  //       //      child: const Icon(
  //       //         Icons.share_rounded,
  //       //          color: Colors.white,
  //       //         size: 24,
  //       //       ),
  //       //      ),
  //       // ),
  //       const SizedBox(height: 16),
  //       Container(
  //         decoration: BoxDecoration(
  //           color: const Color(0xFF1A1A1A).withOpacity(0.9),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: const Color(0xFF333333), width: 1),
  //         ),
  //         child: FloatingActionButton(
  //           heroTag: "scroll_to_top",
  //           onPressed: _scrollToTop,
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           child: const Icon(
  //             Icons.keyboard_arrow_up_rounded,
  //             color: Color(0xFF00F5FF),
  //             size: 28,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Helper methods
  void _toggleLike(PostModel post) async {
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;

    if (currentUser == null) {
      _showLoginRequiredDialog();
      return;
    }

    // Toggle like logic would go here
    final success = await context.read<PostProvider>().toggleLike(post.id);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update like'),
          backgroundColor: const Color(0xFFFF4757),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _sharePost() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality will be implemented'),
        backgroundColor: const Color(0xFF00F5FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // void _savePost(PostModel post) {
  //   // Implement save functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Post saved!'),
  //       backgroundColor: const Color(0xFF00FF87),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );
  // }

  // void _submitComment() {
  //   if (_commentController.text.trim().isEmpty) return;

  //   final authProvider = context.read<AuthProvider>();
  //   if (authProvider.user == null) {
  //     _showLoginRequiredDialog();
  //     return;
  //   }

  //   // Implement comment submission
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Comment added: ${_commentController.text}'),
  //       backgroundColor: const Color(0xFF00FF87),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );

  //   _commentController.clear();
  //   setState(() => _isCommentFocused = false);
  // }

  // void _loadComments(PostModel post) {
  //   // Implement comment loading
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Loading comments...'),
  //       backgroundColor: const Color(0xFF00F5FF),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );
  // }

  void _showPostOptions(PostModel post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.share_rounded,
                color: Color(0xFF00F5FF),
              ),
              title: const Text(
                'Share Post',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _sharePost();
              },
            ),
            // ListTile(
            //   leading: const Icon(
            //     Icons.bookmark_border_rounded,
            //     color: Color(0xFF00F5FF),
            //   ),
            //   title: const Text(
            //     'Save Post',
            //     style: TextStyle(color: Colors.white),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _savePost(post);
            //   },
            // ),
            ListTile(
              leading: const Icon(
                Icons.report_outlined,
                color: Color(0xFFFF4757),
              ),
              title: const Text(
                'Report Post',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportPost(post);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _reportPost(PostModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post reported'),
        backgroundColor: const Color(0xFFFF4757),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Login Required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Please log in to interact with posts.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
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
