import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sneaker_provider.dart';
import '../widgets/responsive_widgets.dart';
import 'brand_sneakers_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPageIndex = 0;

  // Featured sneakers for the top carousel (new/upcoming releases)
  final List<Map<String, dynamic>> _featuredSneakers = [
    {
      'name': 'Air Jordan 4 "Black Cat"',
      'brand': 'Nike',
      'status': 'Coming Soon',
      'releaseDate': 'Oct 2025',
      'price': '\$210',
      'image': '🔥',
      'gradient': [Color(0xFF1A1A1A), Color(0xFF000000)],
    },
    {
      'name': 'Dunk Low "Panda"',
      'brand': 'Nike',
      'status': 'New Release',
      'releaseDate': 'Available Now',
      'price': '\$110',
      'image': '👟',
      'gradient': [Color(0xFF00F5FF), Color(0xFF0080FF)],
    },
    {
      'name': 'Yeezy Boost 350 V2',
      'brand': 'Adidas',
      'status': 'Limited Edition',
      'releaseDate': 'Nov 2025',
      'price': '\$230',
      'image': '⚡',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    },
    {
      'name': 'Stan Smith "Green"',
      'brand': 'Adidas',
      'status': 'Classic',
      'releaseDate': 'Available',
      'price': '\$85',
      'image': '🌟',
      'gradient': [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    },
  ];

  // Popular sneaker brands with their icons
  final List<Map<String, dynamic>> _brands = [
    {
      'name': 'Nike',
      'icon': '✓',
      'color': Color(0xFFFF6B35),
      'description': 'Just Do It',
    },
    {
      'name': 'Adidas',
      'icon': '△',
      'color': Color(0xFF000000),
      'description': 'Three Stripes',
    },
    {
      'name': 'Puma',
      'icon': '🐾',
      'color': Color(0xFF000000),
      'description': 'Forever Faster',
    },
    {
      'name': 'New Balance',
      'icon': 'N',
      'color': Color(0xFF1B5E20),
      'description': 'Fearlessly Independent',
    },
    {
      'name': 'Converse',
      'icon': '★',
      'color': Color(0xFF000000),
      'description': 'All Star',
    },
    {
      'name': 'Vans',
      'icon': 'V',
      'color': Color(0xFF000000),
      'description': 'Off The Wall',
    },
    {
      'name': 'Reebok',
      'icon': 'R',
      'color': Color(0xFF000000),
      'description': 'Be More Human',
    },
    {
      'name': 'ASICS',
      'icon': 'A',
      'color': Color(0xFF0066CC),
      'description': 'Sound Mind, Sound Body',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Auto-scroll the featured sneakers carousel
    _startAutoScroll();

    // Load popular brands
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SneakerProvider>().loadPopularBrands();
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentPageIndex =
              (_currentPageIndex + 1) % _featuredSneakers.length;
        });

        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );

        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Top padding for extended app bar
            SizedBox(height: MediaQuery.of(context).padding.top + 80),

            // Featured sneakers carousel
            _buildFeaturedCarousel(),

            const SizedBox(height: 24),

            // Brands section with bottom padding for floating nav
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 75,
                ), // Adjusted for 65px nav
                child: _buildBrandsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                // Title with gradient
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ).createShader(bounds),
                    child: const Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Notification/Filter icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 20)),
                const Text(
                  'New & Upcoming',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const Spacer(),
                // Text(
                //   'Swipe to explore',
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.6),
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),

          // Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemCount: _featuredSneakers.length,
              itemBuilder: (context, index) {
                return _buildFeaturedCard(_featuredSneakers[index]);
              },
            ),
          ),

          // Page indicators
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featuredSneakers.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPageIndex == index ? 20 : 8,
                height: 5,
                decoration: BoxDecoration(
                  color: _currentPageIndex == index
                      ? const Color(0xFF00F5FF)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> sneaker) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: sneaker['gradient'],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to sneaker details or brand page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coming soon: ${sneaker['name']}'),
                backgroundColor: const Color(0xFF1A1A1A),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sneaker['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Spacer(),

                // Sneaker emoji/image
                Text(sneaker['image'], style: const TextStyle(fontSize: 40)),

                const SizedBox(height: 8),

                // Brand
                Text(
                  sneaker['brand'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Sneaker name
                Text(
                  sneaker['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Release date and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sneaker['releaseDate'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      sneaker['price'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text('👟 ', style: TextStyle(fontSize: 20)),
              const Text(
                'Browse by Brand',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Tap to explore',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 0),

          // Brands grid
          Expanded(
            child: ResponsiveColumns(
              mobileColumns: 2,
              tabletColumns: 3,
              desktopColumns: 4,
              children: _brands
                  .asMap()
                  .entries
                  .map(
                    (entry) => AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (entry.key * 100)),
                      curve: Curves.easeOutCubic,
                      child: _buildBrandCard(entry.value),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(Map<String, dynamic> brand) {
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
          onTap: () => _navigateToBrandSneakers(brand['name']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: brand['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: brand['color'].withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      brand['icon'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brand['color'],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Brand name
                Text(
                  brand['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Brand description
                Text(
                  brand['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBrandSneakers(String brandName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrandSneakersScreen(brandName: brandName),
      ),
    );
  }
}
