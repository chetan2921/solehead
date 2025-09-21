import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../utils/constants.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'search_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, isMobile, isTablet, isDesktop) {
        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildTabletDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      extendBody: true, // This allows content to extend behind the nav bar
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          FeedScreen(),
          ExploreScreen(),
          SearchScreen(),
          CreatePostScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 65, // Even thinner for modern look
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25), // Better margins
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.95), // Semi-transparent
          borderRadius: BorderRadius.circular(20), // More rounded
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF00F5FF).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildModernNavItem(
                Icons.explore_outlined,
                Icons.explore,
                'Explore',
                1,
              ),
              _buildModernNavItem(
                Icons.search_outlined,
                Icons.search,
                'Search',
                2,
              ),
              _buildModernNavItem(
                Icons.add_box_outlined,
                Icons.add_box,
                'Create',
                3,
              ),
              _buildModernNavItem(
                Icons.person_outlined,
                Icons.person,
                'Profile',
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ), // Prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: isSelected ? 36 : 28, // Reduced sizes
                height: isSelected ? 36 : 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSelected ? 14 : 10),
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: isSelected ? 18 : 22, // Reduced icon sizes
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 3), // Reduced spacing
              Flexible(
                // Prevent text overflow
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isSelected ? 9 : 8, // Smaller text
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF00F5FF)
                        : Colors.white.withOpacity(0.5),
                    height: 1.0, // Tight line height
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: AppColors.surface,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            unselectedIconTheme: IconThemeData(
              color: AppColors.onSurface.withOpacity(0.6),
            ),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text('Explore'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box),
                label: Text('Create'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),

          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                FeedScreen(),
                ExploreScreen(),
                SearchScreen(),
                CreatePostScreen(),
                ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
