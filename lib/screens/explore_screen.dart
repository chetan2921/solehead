import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sneaker_provider.dart';
import '../widgets/responsive_widgets.dart';

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
  String? _selectedBrand; // null means show all brands

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

  // Popular sneaker brands with their sample sneakers
  final List<Map<String, dynamic>> _brands = [
    {
      'name': 'Nike',
      'icon': '✓',
      'logo': 'assets/images/Nike/Nike_Logo_1.png',
      'color': Color(0xFFFF6B35),
      'description': 'Just Do It',
      'sneakers': [
        {'name': 'Air Jordan 1 High', 'image': '👟', 'price': '\$170'},
        {'name': 'Air Max 90', 'image': '👟', 'price': '\$130'},
        {'name': 'Dunk Low', 'image': '👟', 'price': '\$110'},
        {'name': 'Air Force 1', 'image': '👟', 'price': '\$90'},
        {'name': 'Blazer Mid', 'image': '👟', 'price': '\$100'},
        {'name': 'Air Max 97', 'image': '👟', 'price': '\$175'},
      ],
    },
    {
      'name': 'Adidas',
      'icon': '△',
      'logo': 'assets/images/Adidas/Adidas_Logo_1.png',
      'color': Color(0xFF000000),
      'description': 'Three Stripes',
      'sneakers': [
        {'name': 'Yeezy Boost 350', 'image': '👟', 'price': '\$220'},
        {'name': 'Stan Smith', 'image': '👟', 'price': '\$85'},
        {'name': 'Superstar', 'image': '👟', 'price': '\$80'},
        {'name': 'Ultraboost', 'image': '👟', 'price': '\$180'},
        {'name': 'Forum Low', 'image': '👟', 'price': '\$110'},
      ],
    },
    {
      'name': 'New Balance',
      'icon': 'N',
      'logo': 'assets/images/New Balance/New Balance_idKm94UNbI_1.png',
      'color': Color(0xFF1B5E20),
      'description': 'Fearlessly Independent',
      'sneakers': [
        {'name': '550', 'image': '👟', 'price': '\$110'},
        {'name': '990v5', 'image': '👟', 'price': '\$185'},
        {'name': '327', 'image': '👟', 'price': '\$90'},
        {'name': '2002R', 'image': '👟', 'price': '\$150'},
      ],
    },
    {
      'name': 'Converse',
      'icon': '★',
      'logo': 'assets/images/Converse/Converse_idJct6otBl_1.png',
      'color': Color.fromARGB(255, 163, 148, 148),
      'description': 'All Star',
      'sneakers': [
        {'name': 'Chuck 70 High', 'image': '👟', 'price': '\$85'},
        {'name': 'Chuck Taylor Low', 'image': '👟', 'price': '\$55'},
        {'name': 'One Star', 'image': '👟', 'price': '\$75'},
        {'name': 'Run Star Hike', 'image': '👟', 'price': '\$110'},
      ],
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
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            bottom: 75, // For floating nav
          ),
          children: [
            // Featured sneakers carousel
            _buildFeaturedCarousel(),

            const SizedBox(height: 24),

            // Brand filter chips
            _buildBrandFilter(),

            const SizedBox(height: 16),

            // Continuous Pinterest-style grid
            _buildContinuousGrid(),
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

  Widget _buildBrandFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All brands chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: _selectedBrand == null,
              onSelected: (selected) {
                setState(() {
                  _selectedBrand = null;
                });
              },
              backgroundColor: const Color(0xFF1A1A1A),
              selectedColor: const Color(0xFF00F5FF),
              labelStyle: TextStyle(
                color: _selectedBrand == null ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: _selectedBrand == null
                    ? const Color(0xFF00F5FF)
                    : Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          // Individual brand chips with logos
          ..._brands.map((brand) {
            final brandName = brand['name'] as String;
            final brandLogo = brand['logo'] as String?;
            final isSelected = _selectedBrand == brandName;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (brandLogo != null)
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isSelected ? Colors.black : Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          brandLogo,
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              brand['icon'],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    if (brandLogo != null) const SizedBox(width: 8),
                    Text(brandName),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedBrand = selected ? brandName : null;
                  });
                },
                backgroundColor: const Color(0xFF1A1A1A),
                selectedColor: const Color(0xFF00F5FF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF00F5FF)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContinuousGrid() {
    // Flatten all sneakers from all brands
    final allSneakers = <Map<String, dynamic>>[];
    for (var brand in _brands) {
      final sneakers =
          (brand['sneakers'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      for (var sneaker in sneakers) {
        allSneakers.add({...sneaker, 'brand': brand});
      }
    }

    // Filter by selected brand if any
    final filteredSneakers = _selectedBrand == null
        ? allSneakers
        : allSneakers
              .where((s) => s['brand']['name'] == _selectedBrand)
              .toList();

    if (filteredSneakers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'No sneakers found',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildPinterestGrid(filteredSneakers),
    );
  }

  Widget _buildPinterestGrid(List<Map<String, dynamic>> sneakers) {
    // Split sneakers into two columns
    final leftColumn = <Map<String, dynamic>>[];
    final rightColumn = <Map<String, dynamic>>[];

    for (int i = 0; i < sneakers.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(sneakers[i]);
      } else {
        rightColumn.add(sneakers[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            children: leftColumn
                .map((sneaker) => _buildSneakerImageCard(sneaker))
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        // Right column
        Expanded(
          child: Column(
            children: rightColumn
                .map((sneaker) => _buildSneakerImageCard(sneaker))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSneakerImageCard(Map<String, dynamic> sneaker) {
    // Random height variation for Pinterest effect
    final heights = [180.0, 200.0, 160.0, 220.0, 190.0, 210.0, 170.0, 230.0];
    final height = heights[sneaker.hashCode % heights.length];
    final brand = sneaker['brand'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/sneaker-detail',
              arguments: {'sneaker': sneaker, 'brand': brand},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
                ),
              ),
              child: Center(
                child: Text(
                  sneaker['image'],
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
