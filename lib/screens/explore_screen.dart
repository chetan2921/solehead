import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sneaker_model.dart';
import '../providers/sneaker_provider.dart';
import '../widgets/common_widgets.dart' as widgets;
import '../widgets/responsive_widgets.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _searchDebounce;
  int _currentPageIndex = 0;
  String? _selectedBrand; // null means show all brands
  bool _isSearching = false;
  final List<List<Color>> _featuredGradients = const [
    [Color(0xFF1A1A1A), Color(0xFF000000)],
    [Color(0xFF00F5FF), Color(0xFF0080FF)],
    [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    [Color(0xFFFFD166), Color(0xFFFFA17F)],
  ];
  List<String> _shuffledSneakerIds = [];
  int? _shuffleSeed;

  @override
  void initState() {
    super.initState();
    _resetShuffle(withSetState: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController.addListener(_handleScroll);

    // Auto-scroll the featured sneakers carousel
    _startAutoScroll();

    // Load popular brands
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SneakerProvider>();
      provider.loadSneakers(refresh: true);
      provider.loadPopularBrands();
      provider.loadTopSneakers(refresh: true);
    });
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final featuredCount = context.read<SneakerProvider>().topSneakers.length;

      if (featuredCount <= 1) {
        _startAutoScroll();
        return;
      }

      setState(() {
        _currentPageIndex = (_currentPageIndex + 1) % featuredCount;
      });

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }

      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;
    final provider = context.read<SneakerProvider>();
    if (provider.isLoading || !provider.hasMoreSneakers) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      provider.loadSneakers();
    }
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim();
    _searchDebounce?.cancel();
    setState(() {
      _isSearching = trimmed.isNotEmpty;
    });

    if (trimmed.isEmpty) {
      context.read<SneakerProvider>().clearSearchResults();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      context.read<SneakerProvider>().searchSneakers(trimmed);
    });
  }

  Future<void> _handleExploreRefresh() async {
    final provider = context.read<SneakerProvider>();
    _resetShuffle();
    await Future.wait([
      provider.loadSneakers(refresh: true),
      provider.loadTopSneakers(refresh: true),
      provider.loadPopularBrands(),
    ]);
  }

  void _resetShuffle({bool withSetState = true}) {
    final seed = DateTime.now().millisecondsSinceEpoch;
    void updateState() {
      _shuffleSeed = seed;
      _shuffledSneakerIds = [];
    }

    if (!mounted || !withSetState) {
      updateState();
    } else {
      setState(updateState);
    }
  }

  void _syncShuffledOrder(List<SneakerModel> catalog) {
    if (catalog.isEmpty) return;

    final allIds = catalog.map((s) => s.id).toList();
    if (allIds.isEmpty) return;

    final catalogSet = allIds.toSet();
    final retained = _shuffledSneakerIds
        .where((id) => catalogSet.contains(id))
        .toList();
    final retainedSet = retained.toSet();
    final missing = [
      for (final id in allIds)
        if (!retainedSet.contains(id)) id,
    ];

    if (missing.isEmpty && retained.length == _shuffledSneakerIds.length) {
      return;
    }

    final seed = _shuffleSeed ?? DateTime.now().millisecondsSinceEpoch;
    _shuffleSeed = seed;
    final random = Random(seed + retained.length);
    final shuffledMissing = List<String>.from(missing)..shuffle(random);
    _shuffledSneakerIds = [...retained, ...shuffledMissing];
  }

  List<SneakerModel> _orderByShuffle(List<SneakerModel> sneakers) {
    if (sneakers.isEmpty || _shuffledSneakerIds.isEmpty) {
      return sneakers;
    }

    final lookup = <String, SneakerModel>{
      for (final sneaker in sneakers) sneaker.id: sneaker,
    };

    final ordered = <SneakerModel>[];
    for (final id in _shuffledSneakerIds) {
      final sneaker = lookup.remove(id);
      if (sneaker != null) {
        ordered.add(sneaker);
      }
    }

    if (lookup.isNotEmpty) {
      ordered.addAll(lookup.values);
    }

    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: ResponsiveContainer(
        child: RefreshIndicator(
          color: const Color(0xFF00F5FF),
          backgroundColor: const Color(0xFF0A0A0A),
          onRefresh: _handleExploreRefresh,
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 80,
              bottom: 75, // For floating nav
            ),
            children: [
              // Featured sneakers carousel
              _buildFeaturedCarousel(),

              const SizedBox(height: 24),

              // Trending section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('📈 ', style: TextStyle(fontSize: 20)),
                    Text(
                      _isSearching ? 'Catalog Results' : 'Trending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildExploreSearchBar(),

              const SizedBox(height: 16),

              // Continuous Pinterest-style grid
              _buildContinuousGrid(),
            ],
          ),
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

                // Filter icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedBrand != null
                        ? const Color(0xFF00F5FF).withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBrand != null
                          ? const Color(0xFF00F5FF)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: _showBrandFilterDialog,
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: _selectedBrand != null
                          ? const Color(0xFF00F5FF)
                          : Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Search icon
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
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
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
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<SneakerProvider>(
        builder: (context, sneakerProvider, child) {
          final featured = sneakerProvider.topSneakers;
          final isLoading =
              sneakerProvider.isTopSneakersLoading && featured.isEmpty;
          final error = sneakerProvider.topSneakersError;

          if (isLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: _featuredShellDecoration(),
                    padding: const EdgeInsets.all(24),
                    child: const widgets.LoadingWidget(
                      message: 'Fetching catalog heat...',
                    ),
                  ),
                ),
              ],
            );
          }

          if (featured.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildFeaturedEmptyState(error, sneakerProvider),
                ),
              ],
            );
          }

          final pageCount = featured.length;

          if (_currentPageIndex >= pageCount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final safeIndex = pageCount - 1;
              if (safeIndex >= 0 && _pageController.hasClients) {
                _pageController.jumpToPage(safeIndex);
              }
              if (safeIndex >= 0) {
                setState(() {
                  _currentPageIndex = safeIndex;
                });
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedHeader(),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    return _buildFeaturedCard(featured[index], index);
                  },
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (index) {
                  final isActive = (_currentPageIndex % pageCount) == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 8,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00F5FF)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExploreSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search any sneaker, any brand',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          prefixIcon: Icon(
            Icons.search,
            color: _isSearching ? const Color(0xFF00F5FF) : Colors.white70,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00F5FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(SneakerModel sneaker, int index) {
    final gradient = _featuredGradients[index % _featuredGradients.length];
    final releaseLabel = _releaseLabel(sneaker);
    final metaSummary = _metadataSummary(sneaker);
    final highlightChips = _metadataHighlights(sneaker);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
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
            Navigator.pushNamed(context, '/sneaker-detail', arguments: sneaker);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    releaseLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(child: _buildFeaturedImage(sneaker)),

                const SizedBox(height: 16),

                Text(
                  sneaker.brandName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  sneaker.sneakerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Text(
                  metaSummary,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatSneakerPrice(sneaker),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _ratingDisplay(sneaker),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (highlightChips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: highlightChips
                        .take(3)
                        .map(_buildFeaturedMetaChip)
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinuousGrid() {
    return Consumer<SneakerProvider>(
      builder: (context, sneakerProvider, child) {
        final catalog = _isSearching
            ? sneakerProvider.searchResults
            : sneakerProvider.sneakers;

        final isInitialLoad = sneakerProvider.isLoading && catalog.isEmpty;
        if (isInitialLoad) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: widgets.LoadingWidget(
              message: _isSearching
                  ? 'Searching the catalog...'
                  : 'Fetching drops...',
            ),
          );
        }

        if (catalog.isEmpty && sneakerProvider.error != null) {
          return widgets.ErrorWidget(
            message: sneakerProvider.error!,
            onRetry: () => _isSearching
                ? sneakerProvider.searchSneakers(_searchController.text.trim())
                : sneakerProvider.loadSneakers(refresh: true),
          );
        }

        List<SneakerModel> filtered = catalog;
        if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
          filtered = catalog
              .where(
                (sneaker) =>
                    sneaker.brandName.toLowerCase() ==
                    _selectedBrand!.toLowerCase(),
              )
              .toList();
        }

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: widgets.EmptyStateWidget(
              title: _isSearching ? 'No matches found' : 'No sneakers found',
              message: _isSearching
                  ? 'We couldn\'t find "${_searchController.text}" in the catalog.'
                  : 'Try another brand or clear the filter to see all drops.',
              icon: Icons.travel_explore,
            ),
          );
        }

        if (!_isSearching) {
          _syncShuffledOrder(catalog);
        }

        final displaySneakers = _isSearching
            ? filtered
            : _orderByShuffle(filtered);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${displaySneakers.length} results',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPinterestGrid(displaySneakers),
            ),
            const SizedBox(height: 20),
            if (_isSearching && sneakerProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(color: Color(0xFF00F5FF)),
              )
            else if (!_isSearching && sneakerProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF00F5FF)),
              )
            else if (!_isSearching && sneakerProvider.hasMoreSneakers)
              Center(
                child: TextButton.icon(
                  onPressed: () => sneakerProvider.loadSneakers(),
                  icon: const Icon(Icons.refresh, color: Color(0xFF00F5FF)),
                  label: const Text(
                    'Load more drops',
                    style: TextStyle(color: Color(0xFF00F5FF)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showBrandFilterDialog() {
    final sneakerProvider = context.read<SneakerProvider>();
    final brandSet = <String>{};
    brandSet.addAll(
      sneakerProvider.popularBrands
          .map((brand) => brand.trim())
          .where((brand) => brand.isNotEmpty),
    );
    brandSet.addAll(
      sneakerProvider.sneakers
          .map((s) => s.brandName)
          .where((brand) => brand.trim().isNotEmpty),
    );
    brandSet.addAll(
      sneakerProvider.searchResults
          .map((s) => s.brandName)
          .where((brand) => brand.trim().isNotEmpty),
    );
    final brands = brandSet.toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Brand',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedBrand != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedBrand = null);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF00F5FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildBrandFilterOption(
                    name: 'All Brands',
                    isSelected: _selectedBrand == null,
                    onTap: () {
                      setState(() => _selectedBrand = null);
                      Navigator.pop(context);
                    },
                  ),
                  ...brands.map(
                    (brand) => _buildBrandFilterOption(
                      name: brand,
                      isSelected: _selectedBrand == brand,
                      onTap: () {
                        setState(() => _selectedBrand = brand);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandFilterOption({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = _brandAccentColor(name);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF00F5FF).withOpacity(0.1)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00F5FF)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00F5FF)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view ${name.toUpperCase()} drops',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinterestGrid(List<SneakerModel> sneakers) {
    final leftColumn = <SneakerModel>[];
    final rightColumn = <SneakerModel>[];

    for (int i = 0; i < sneakers.length; i++) {
      if (i.isEven) {
        leftColumn.add(sneakers[i]);
      } else {
        rightColumn.add(sneakers[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map((sneaker) => _buildSneakerImageCard(sneaker))
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
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

  Widget _buildSneakerImageCard(SneakerModel sneaker) {
    final heights = [180.0, 200.0, 160.0, 220.0, 190.0, 210.0, 170.0, 230.0];
    final height = heights[sneaker.hashCode % heights.length];
    final imageUrl = sneaker.photoUrl;
    final brandColor = _brandAccentColor(sneaker.brandName);
    final detailHighlights = _metadataHighlights(sneaker);
    final infoRows = _detailInfoRows(sneaker);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/sneaker-detail', arguments: sneaker);
          },
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl.isNotEmpty)
                  widgets.CachedImageWidget(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          brandColor.withOpacity(0.2),
                          const Color(0xFF1A1A1A),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sneaker.brandName.isNotEmpty
                            ? sneaker.brandName.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: brandColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      sneaker.brandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sneaker.sneakerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatSneakerPrice(sneaker),
                              style: TextStyle(
                                color: brandColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _ratingDisplay(sneaker),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (detailHighlights.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: detailHighlights
                                  .take(2)
                                  .map(
                                    (label) =>
                                        _buildGridMetaChip(label, brandColor),
                                  )
                                  .toList(),
                            ),
                          ),
                        if (infoRows.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: infoRows
                                  .map(
                                    (row) =>
                                        _buildDetailInfoRow(row, brandColor),
                                  )
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: const [
          Text('🔥 ', style: TextStyle(fontSize: 20)),
          Text(
            'New & Upcoming',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _featuredShellDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
    );
  }

  Widget _buildFeaturedEmptyState(String? error, SneakerProvider provider) {
    return Container(
      decoration: _featuredShellDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_rounded,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sync catalog to view fresh drops',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => provider.loadTopSneakers(refresh: true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF00F5FF)),
              foregroundColor: const Color(0xFF00F5FF),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh catalog'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedImage(SneakerModel sneaker) {
    return AspectRatio(
      aspectRatio: 1.35,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: sneaker.photoUrl.isNotEmpty
              ? widgets.CachedImageWidget(
                  imageUrl: sneaker.photoUrl,
                  fit: BoxFit.cover,
                )
              : _buildImageFallback(sneaker.brandName),
        ),
      ),
    );
  }

  Widget _buildImageFallback(String brand) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
      ),
      child: Center(
        child: Text(
          brand.isNotEmpty ? brand.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _releaseLabel(SneakerModel sneaker) {
    final metadataStatus = _extractMetadataValue(sneaker, const [
      'status',
      'dropType',
      'releaseDate',
      'release_date',
      'launchDate',
    ]);
    if (metadataStatus != null) {
      return metadataStatus;
    }
    if (sneaker.createdAt != null) {
      final days = DateTime.now().difference(sneaker.createdAt!).inDays;
      if (days <= 30) {
        return 'New this month';
      }
      return 'Added ${sneaker.createdAt!.year}';
    }
    return 'Catalog favorite';
  }

  String _metadataSummary(SneakerModel sneaker) {
    final summary = _extractMetadataValue(sneaker, const [
      'colorway',
      'color',
      'collection',
    ]);
    if (summary != null) {
      return _truncateText(summary, max: 80);
    }
    if (sneaker.description.isNotEmpty) {
      return _truncateText(sneaker.description, max: 90);
    }
    if (sneaker.sourceFile?.isNotEmpty == true) {
      return 'Source: ${sneaker.sourceFile!}';
    }
    return 'Tap to explore the drop story';
  }

  List<String> _metadataHighlights(SneakerModel sneaker) {
    final highlights = <String>[];
    const keys = ['colorway', 'collection', 'styleCode', 'year', 'gender'];
    for (final key in keys) {
      final value = _extractMetadataValue(sneaker, [key]);
      if (value != null) {
        String label;
        switch (key) {
          case 'styleCode':
            label = 'Style $value';
            break;
          case 'year':
            label = 'Year $value';
            break;
          default:
            label = value;
        }
        label = _truncateText(label, max: 26);
        if (!highlights.contains(label)) {
          highlights.add(label);
        }
      }
      if (highlights.length >= 3) break;
    }
    if (highlights.isEmpty &&
        sneaker.metadataOriginalRowHash?.isNotEmpty == true) {
      highlights.add(
        _truncateText('ID ${sneaker.metadataOriginalRowHash!}', max: 26),
      );
    }
    return highlights;
  }

  List<MapEntry<String, String>> _detailInfoRows(SneakerModel sneaker) {
    final rows = <MapEntry<String, String>>[];

    void addRow(String label, String? value, {int max = 42}) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == 'See details') return;
      rows.add(MapEntry(label, _truncateText(trimmed, max: max)));
    }

    addRow(
      'Release',
      _extractMetadataValue(sneaker, const [
        'releaseDate',
        'release_date',
        'launchDate',
        'status',
      ]),
    );
    addRow(
      'Colorway',
      _extractMetadataValue(sneaker, const ['colorway', 'color']),
    );
    addRow(
      'Style',
      _extractMetadataValue(sneaker, const [
        'styleCode',
        'sku',
        'productSku',
        'modelNumber',
      ]),
    );
    addRow(
      'Gender',
      _extractMetadataValue(sneaker, const ['gender', 'audience']),
    );
    final priceDisplay = _formatSneakerPrice(sneaker);
    if (priceDisplay != 'See details') {
      addRow('Price', priceDisplay, max: 32);
    } else {
      addRow('Price', sneaker.priceRaw);
    }
    addRow('Source', sneaker.sourceFile, max: 36);
    if (sneaker.metadataOriginalRowHash?.isNotEmpty == true) {
      addRow('Row ID', '#${sneaker.metadataOriginalRowHash!}', max: 30);
    }

    return rows.take(4).toList();
  }

  String? _extractMetadataValue(SneakerModel sneaker, List<String> keys) {
    for (final key in keys) {
      final value = _metadataValue(sneaker, key);
      final stringValue = _stringifyMetadataValue(value);
      if (stringValue != null && stringValue.isNotEmpty) {
        return stringValue;
      }
    }
    return null;
  }

  dynamic _metadataValue(SneakerModel sneaker, String key) {
    final metadata = sneaker.metadata;
    if (metadata == null) return null;
    final target = key.toLowerCase();
    for (final entry in metadata.entries) {
      if (entry.key.toString().toLowerCase() == target) {
        return entry.value;
      }
    }
    return null;
  }

  String? _stringifyMetadataValue(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is List && value.isNotEmpty) {
      return _stringifyMetadataValue(value.first);
    }
    if (value is Map && value['value'] != null) {
      return _stringifyMetadataValue(value['value']);
    }
    final stringified = value.toString().trim();
    return stringified.isEmpty ? null : stringified;
  }

  String _truncateText(String value, {int max = 80}) {
    if (value.length <= max) return value;
    return '${value.substring(0, max - 1)}…';
  }

  Widget _buildFeaturedMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGridMetaChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.5), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailInfoRow(MapEntry<String, String> row, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            row.key,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              row.value,
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingDisplay(SneakerModel sneaker) {
    if (sneaker.ratingCount > 0) {
      return '${sneaker.averageRating.toStringAsFixed(1)} (${sneaker.ratingCount})';
    }
    return 'New';
  }

  Color _brandAccentColor(String brand) {
    const palette = [
      Color(0xFF00F5FF),
      Color(0xFFFF6B6B),
      Color(0xFFFFD166),
      Color(0xFF8E24AA),
      Color(0xFF4CAF50),
      Color(0xFFFF8E72),
      Color(0xFF64B5F6),
    ];
    final normalized = brand.toLowerCase();
    final index = normalized.hashCode.abs() % palette.length;
    return palette[index];
  }

  String _formatSneakerPrice(SneakerModel sneaker) {
    if (sneaker.price != null) {
      final currency = sneaker.currency?.toUpperCase();
      final symbol = _currencySymbol(currency);
      final value = sneaker.price!;
      final formatted = value % 1 == 0
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
      if (symbol != null) {
        return '$symbol$formatted';
      }
      if (currency != null && currency.isNotEmpty) {
        return '$formatted $currency';
      }
      return formatted;
    }

    if (sneaker.priceRaw?.isNotEmpty == true) {
      return sneaker.priceRaw!;
    }

    return 'See details';
  }

  String? _currencySymbol(String? currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'INR':
        return '₹';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return null;
    }
  }
}
