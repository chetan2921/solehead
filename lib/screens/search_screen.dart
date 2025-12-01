import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sneaker_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../models/sneaker_model.dart';
import '../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to update search hint when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SneakerProvider>().loadTopSneakers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      if (_tabController.index == 0) {
        context.read<SneakerProvider>().searchSneakers(query);
      } else {
        context.read<UserProvider>().searchUsers(query);
      }
    } else {
      context.read<SneakerProvider>().clearSearchResults();
    }
  }

  Widget _buildLoadingState(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 75.0), // Adjusted for 65px nav
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5FF)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 75.0), // Adjusted for 65px nav
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
    bool showAction = false,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 75.0), // Adjusted for 65px nav
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showAction && onAction != null && actionText != null) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.explore_rounded, size: 18),
                    label: Text(
                      actionText,
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(context),
      body: CustomScrollView(
        slivers: [
          // Add spacing for the AppBar
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120 + MediaQuery.of(context).padding.top,
            ), // Match AppBar toolbarHeight + safe area
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF00F5FF),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.sports_baseball_outlined, size: 20),
                    text: 'Sneakers',
                    height: 48,
                  ),
                  Tab(
                    icon: Icon(Icons.people_outline, size: 20),
                    text: 'Users',
                    height: 48,
                  ),
                ],
              ),
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSneakersTab(), _buildUsersTab()],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Remove default back button
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with back button
                    Row(
                      children: [
                        // Back button
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          // decoration: BoxDecoration(
                          //   color: const Color(0xFF1A1A1A).withOpacity(0.8),
                          //   borderRadius: BorderRadius.circular(12),
                          //   border: Border.all(
                          //     color: const Color(0xFF333333),
                          //     width: 1,
                          //   ),
                          // ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        // Title with gradient
                        Flexible(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                            ).createShader(bounds),
                            child: const Text(
                              'Discover',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Modern search bar with proper constraints
                    Flexible(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: _tabController.index == 0
                                ? 'Search sneakers...'
                                : 'Search users...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.search_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                            suffixIcon: _isSearching
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      child: Icon(
                                        Icons.clear_rounded,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 18,
                                      ),
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSneakersTab() {
    return Consumer<SneakerProvider>(
      builder: (context, sneakerProvider, child) {
        List<SneakerModel> sneakers = _isSearching
            ? sneakerProvider.searchResults
            : sneakerProvider.topSneakers;
        final bool isLoading = _isSearching
            ? sneakerProvider.isLoading
            : sneakerProvider.isTopSneakersLoading;
        final String? errorMessage = _isSearching
            ? sneakerProvider.error
            : sneakerProvider.topSneakersError;

        if (sneakers.isEmpty && isLoading) {
          return _buildLoadingState(
            _isSearching ? 'Searching sneakers...' : 'Loading top sneakers...',
          );
        }

        if (sneakers.isEmpty && errorMessage != null) {
          return _buildErrorState(
            errorMessage,
            () => _isSearching
                ? sneakerProvider.searchSneakers(_searchController.text)
                : sneakerProvider.loadTopSneakers(refresh: true),
          );
        }

        if (sneakers.isEmpty) {
          return _buildEmptyState(
            title: _isSearching ? 'No sneakers found' : 'Discover Top Sneakers',
            message: _isSearching
                ? 'Try searching with different keywords'
                : 'Top rated sneakers will appear here',
            icon: Icons.sports_baseball_outlined,
            showAction: !_isSearching,
            actionText: 'Explore Sneakers',
            onAction: () => sneakerProvider.loadTopSneakers(refresh: true),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (_isSearching) {
              await sneakerProvider.searchSneakers(_searchController.text);
            } else {
              await sneakerProvider.loadTopSneakers(refresh: true);
            }
          },
          color: const Color(0xFF00F5FF),
          backgroundColor: const Color(0xFF1A1A1A),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 75.0,
            ), // Adjusted for 65px nav
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: sneakers.length,
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  child: SneakerCard(sneaker: sneakers[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!_isSearching) {
          return _buildEmptyState(
            title: 'Find Sneakerheads',
            message:
                'Search for users to connect with fellow sneaker enthusiasts',
            icon: Icons.person_search_rounded,
            showAction: false,
          );
        }

        if (userProvider.users.isEmpty && userProvider.isLoading) {
          return _buildLoadingState('Searching users...');
        }

        if (userProvider.users.isEmpty && userProvider.error != null) {
          return _buildErrorState(
            userProvider.error!,
            () => userProvider.searchUsers(_searchController.text),
          );
        }

        if (userProvider.users.isEmpty) {
          return _buildEmptyState(
            title: 'No users found',
            message: 'Try searching with different keywords',
            icon: Icons.person_off_outlined,
          );
        }

        return ResponsivePadding(
          child: RefreshIndicator(
            onRefresh: () async {
              await userProvider.searchUsers(_searchController.text);
            },
            color: const Color(0xFF00F5FF),
            backgroundColor: const Color(0xFF1A1A1A),
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 75.0,
              ), // Adjusted for 65px nav
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: userProvider.users.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    child: UserCard(user: userProvider.users[index]),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class SneakerCard extends StatelessWidget {
  final SneakerModel sneaker;

  const SneakerCard({super.key, required this.sneaker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewSneaker(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sneaker image placeholder with gradient
                AspectRatio(
                  aspectRatio: 0.95,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00F5FF).withOpacity(0.1),
                          const Color(0xFF0080FF).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_baseball_rounded,
                      size: 40,
                      color: Color(0xFF00F5FF),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Brand name with styling
                Text(
                  sneaker.brandName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF00F5FF),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 5),

                // Sneaker name with better line height
                Text(
                  sneaker.sneakerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Rating with compact modern design
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 6,
                //     vertical: 3,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.amber.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(6),
                //     border: Border.all(
                //       color: Colors.amber.withOpacity(0.3),
                //       width: 1,
                //     ),
                //   ),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       const Icon(
                //         Icons.star_rounded,
                //         color: Colors.amber,
                //         size: 14,
                //       ),
                //       const SizedBox(width: 3),
                //       Flexible(
                //         child: Text(
                //           '${sneaker.averageRating.toStringAsFixed(1)} (${sneaker.ratingCount})',
                //           style: const TextStyle(
                //             fontSize: 11,
                //             fontWeight: FontWeight.w600,
                //             color: Colors.white,
                //           ),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewSneaker(BuildContext context) {
    // Add haptic feedback
    // HapticFeedback.lightImpact();

    // Navigate to sneaker details screen
    // Navigator.pushNamed(context, '/sneaker', arguments: sneaker);

    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${sneaker.sneakerName}'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewProfile(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // User avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ),
                  ),
                  child: Hero(
                    tag: 'user_avatar_${user.id}',
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A1A1A),
                      backgroundImage: user.profilePhoto.isNotEmpty
                          ? NetworkImage(user.profilePhoto)
                          : null,
                      child: user.profilePhoto.isEmpty
                          ? Text(
                              user.username.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00F5FF),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User info - properly constrained
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Username with proper overflow handling
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 4),

                      // Stats with modern styling - use Wrap for better overflow handling
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildStatChip(
                            '${user.followers}',
                            'followers',
                            Icons.people_outline_rounded,
                          ),
                          _buildStatChip(
                            '${user.totalSneakerCount}',
                            'sneakers',
                            Icons.sports_baseball_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow with gradient background
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00F5FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF00F5FF),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _viewProfile(BuildContext context) {
    // Add haptic feedback
    // HapticFeedback.lightImpact();

    // Navigate to user profile screen
    // Navigator.pushNamed(context, '/profile', arguments: user);

    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${user.username}\'s profile'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
