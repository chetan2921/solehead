import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sneaker_model.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart' as widgets;

class SneakerDetailScreen extends StatefulWidget {
  final SneakerModel sneaker;

  const SneakerDetailScreen({super.key, required this.sneaker});

  @override
  State<SneakerDetailScreen> createState() => _SneakerDetailScreenState();
}

class _SneakerDetailScreenState extends State<SneakerDetailScreen> {
  final PageController _pageController = PageController();
  late final List<String> _galleryImages;

  @override
  void initState() {
    super.initState();
    _galleryImages = _deriveGalleryImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _deriveGalleryImages() {
    final images = <String>[];
    if (widget.sneaker.photoUrl.isNotEmpty) {
      images.add(widget.sneaker.photoUrl);
    }

    final metadataImages = widget.sneaker.metadata?['images'];
    if (metadataImages is List) {
      for (final entry in metadataImages) {
        final url = entry is String
            ? entry
            : (entry is Map<String, dynamic> ? entry['url'] : null);
        if (url is String && url.isNotEmpty && !images.contains(url)) {
          images.add(url);
        }
      }
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),
                _buildImageCarousel(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandChip(),
                  const SizedBox(height: 16),
                  Text(
                    widget.sneaker.sneakerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _priceLabel(),
                    style: const TextStyle(
                      color: Color(0xFF00F5FF),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 12),
                  _buildDescriptionCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Product Details'),
                  const SizedBox(height: 12),
                  _buildDetailItem('Brand', widget.sneaker.brandName),
                  _buildDetailItem(
                    'Average Rating',
                    widget.sneaker.averageRating.toStringAsFixed(1),
                  ),
                  _buildDetailItem(
                    'Ratings',
                    widget.sneaker.ratingCount.toString(),
                  ),
                  _buildDetailItem(
                    'Featured in Posts',
                    widget.sneaker.postCount.toString(),
                  ),
                  if (widget.sneaker.sourceFile?.isNotEmpty == true)
                    _buildDetailItem('Source', widget.sneaker.sourceFile!),
                  if (widget.sneaker.metadataOriginalRowHash?.isNotEmpty ==
                      true)
                    _buildDetailItem(
                      'Catalog ID',
                      widget.sneaker.metadataOriginalRowHash!,
                    ),
                  const SizedBox(height: 24),
                  if (widget.sneaker.sneakerUrl.isNotEmpty)
                    _buildPurchaseButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.9),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              _showMessage('Sharing coming soon');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _galleryImages.isEmpty ? 1 : _galleryImages.length,
            itemBuilder: (context, index) {
              final imageUrl = _galleryImages.isEmpty
                  ? null
                  : _galleryImages[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: imageUrl != null
                      ? widgets.CachedImageWidget(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : _buildEmptyImagePlaceholder(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _galleryImages.isEmpty ? 1 : _galleryImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF00F5FF).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildBrandChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00F5FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        widget.sneaker.brandName,
        style: const TextStyle(
          color: Color(0xFF00F5FF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = widget.sneaker.description.isNotEmpty
        ? widget.sneaker.description
        : 'Experience the perfect blend of heritage design and modern comfort. '
              'Fresh from the SoleHead importer, this drop is ready for your collection.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openPurchaseLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Buy Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => _showMessage('Favorites coming soon'),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showMessage('Collections coming soon'),
          ),
        ),
      ],
    );
  }

  String _priceLabel() {
    if (widget.sneaker.price != null) {
      final currency = widget.sneaker.currency?.toUpperCase();
      final symbol = _currencySymbol(currency);
      final value = widget.sneaker.price!;
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

    if (widget.sneaker.priceRaw?.isNotEmpty == true) {
      return widget.sneaker.priceRaw!;
    }

    return 'Price unavailable';
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

  Future<void> _openPurchaseLink() async {
    final url = widget.sneaker.sneakerUrl;
    if (url.isEmpty) {
      _showMessage('No purchase link available yet');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showMessage('Invalid product link');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showMessage('Could not open link');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
