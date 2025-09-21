import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sneaker_provider.dart';
import '../widgets/responsive_widgets.dart';
import '../models/sneaker_model.dart';

class BrandSneakersScreen extends StatefulWidget {
  final String brandName;

  const BrandSneakersScreen({super.key, required this.brandName});

  @override
  State<BrandSneakersScreen> createState() => _BrandSneakersScreenState();
}

class _BrandSneakersScreenState extends State<BrandSneakersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  // Brand info mapping
  final Map<String, Map<String, dynamic>> _brandInfo = {
    'Nike': {
      'icon': '✓',
      'color': Color(0xFFFF6B35),
      'description': 'Just Do It',
      'founded': '1964',
      'headquarters': 'Oregon, USA',
      'gradient': [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    },
    'Adidas': {
      'icon': '△',
      'color': Color(0xFF000000),
      'description': 'Three Stripes',
      'founded': '1949',
      'headquarters': 'Germany',
      'gradient': [Color(0xFF000000), Color(0xFF333333)],
    },
    'Puma': {
      'icon': '🐾',
      'color': Color(0xFF000000),
      'description': 'Forever Faster',
      'founded': '1948',
      'headquarters': 'Germany',
      'gradient': [Color(0xFF000000), Color(0xFF444444)],
    },
    'New Balance': {
      'icon': 'N',
      'color': Color(0xFF1B5E20),
      'description': 'Fearlessly Independent',
      'founded': '1906',
      'headquarters': 'Massachusetts, USA',
      'gradient': [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    },
    'Converse': {
      'icon': '★',
      'color': Color(0xFF000000),
      'description': 'All Star',
      'founded': '1908',
      'headquarters': 'Massachusetts, USA',
      'gradient': [Color(0xFF000000), Color(0xFF333333)],
    },
    'Vans': {
      'icon': 'V',
      'color': Color(0xFF000000),
      'description': 'Off The Wall',
      'founded': '1966',
      'headquarters': 'California, USA',
      'gradient': [Color(0xFF000000), Color(0xFF333333)],
    },
    'Reebok': {
      'icon': 'R',
      'color': Color(0xFF000000),
      'description': 'Be More Human',
      'founded': '1958',
      'headquarters': 'Massachusetts, USA',
      'gradient': [Color(0xFF000000), Color(0xFF333333)],
    },
    'ASICS': {
      'icon': 'A',
      'color': Color(0xFF0066CC),
      'description': 'Sound Mind, Sound Body',
      'founded': '1949',
      'headquarters': 'Japan',
      'gradient': [Color(0xFF0066CC), Color(0xFF1976D2)],
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(() {
      bool showTitle = _scrollController.offset > 100;
      if (showTitle != _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = showTitle;
        });
      }
    });

    // Load sneakers for this brand
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SneakerProvider>().loadSneakersByBrand(widget.brandName);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentBrandInfo {
    return _brandInfo[widget.brandName] ??
        {
          'icon': '👟',
          'color': const Color(0xFF00F5FF),
          'description': 'Premium Sneakers',
          'founded': 'Unknown',
          'headquarters': 'Global',
          'gradient': [const Color(0xFF00F5FF), const Color(0xFF0080FF)],
        };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: ResponsiveContainer(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Brand header
            SliverToBoxAdapter(child: _buildBrandHeader()),

            // Brand stats
            SliverToBoxAdapter(child: _buildBrandStats()),

            // Sneakers section header
            SliverToBoxAdapter(child: _buildSectionHeader()),

            // Sneakers grid
            _buildSneakersGrid(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.brandName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${widget.brandName} to favorites'),
                  backgroundColor: const Color(0xFF1A1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    final brandInfo = _currentBrandInfo;

    return Container(
      height: 300,
      margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brandInfo['gradient'],
        ),
        boxShadow: [
          BoxShadow(
            color: brandInfo['color'].withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: BrandPatternPainter(brandInfo['color']),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      brandInfo['icon'],
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Brand name
                Text(
                  widget.brandName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                // Brand description
                Text(
                  brandInfo['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Brand details
                Row(
                  children: [
                    _buildBrandDetail('Founded', brandInfo['founded']),
                    const SizedBox(width: 24),
                    _buildBrandDetail('HQ', brandInfo['headquarters']),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Consumer<SneakerProvider>(
        builder: (context, sneakerProvider, child) {
          final sneakerCount = sneakerProvider.searchResults.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Models',
                '$sneakerCount',
                Icons.sports_baseball_outlined,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatItem('Avg Rating', '4.5', Icons.star_rounded),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatItem('Popular', 'Yes', Icons.trending_up_rounded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _currentBrandInfo['color'], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Text(
            '${widget.brandName} Sneakers',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer<SneakerProvider>(
            builder: (context, sneakerProvider, child) {
              return Text(
                '${sneakerProvider.searchResults.length} models',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSneakersGrid() {
    return Consumer<SneakerProvider>(
      builder: (context, sneakerProvider, child) {
        if (sneakerProvider.isLoading &&
            sneakerProvider.searchResults.isEmpty) {
          return SliverToBoxAdapter(child: _buildLoadingState());
        }

        if (sneakerProvider.error != null) {
          return SliverToBoxAdapter(
            child: _buildErrorState(sneakerProvider.error!),
          );
        }

        if (sneakerProvider.searchResults.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final sneaker = sneakerProvider.searchResults[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                child: _buildSneakerCard(sneaker),
              );
            }, childCount: sneakerProvider.searchResults.length),
          ),
        );
      },
    );
  }

  Widget _buildSneakerCard(SneakerModel sneaker) {
    return Container(
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
          onTap: () => _viewSneaker(sneaker),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sneaker image placeholder
                Expanded(
                  flex: 8,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _currentBrandInfo['color'].withOpacity(0.1),
                          _currentBrandInfo['color'].withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.sports_baseball_rounded,
                      size: 40,
                      color: _currentBrandInfo['color'],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // // Brand name
                // Text(
                //   sneaker.brandName,
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     fontSize: 11,
                //     color: _currentBrandInfo['color'],
                //     letterSpacing: 0.3,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
                const SizedBox(height: 1),

                // Sneaker name
                Expanded(
                  flex: 1,
                  child: Text(
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
                ),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${sneaker.averageRating.toStringAsFixed(1)} (${sneaker.ratingCount})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                _currentBrandInfo['color'],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.brandName} sneakers...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<SneakerProvider>().loadSneakersByBrand(
                  widget.brandName,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentBrandInfo['color'],
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.brandName} sneakers yet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new releases',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewSneaker(SneakerModel sneaker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${sneaker.sneakerName}'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Custom painter for brand header background pattern
class BrandPatternPainter extends CustomPainter {
  final Color color;

  BrandPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw some geometric patterns
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8 + i * 20, size.height * 0.2 + i * 15),
        8,
        paint,
      );
    }

    // Draw diagonal lines
    final linePaint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 2;

    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(size.width * 0.7 + i * 15, 0),
        Offset(size.width + i * 15, size.height * 0.3),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
