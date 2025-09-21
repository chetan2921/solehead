import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/post_provider.dart';
import '../widgets/responsive_widgets.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _sneakerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purchaseLinkController = TextEditingController();
  final _purchaseAddressController = TextEditingController();
  final _priceController = TextEditingController();
  final _yearController = TextEditingController();
  final _releaseDateController = TextEditingController();

  File? _mainImage;
  List<File> _additionalImages = [];
  final ImagePicker _picker = ImagePicker();

  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimationController.forward();
    _scaleAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _fabAnimationController.dispose();
    _brandController.dispose();
    _sneakerController.dispose();
    _descriptionController.dispose();
    _purchaseLinkController.dispose();
    _purchaseAddressController.dispose();
    _priceController.dispose();
    _yearController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _additionalImages = images.map((image) => File(image.path)).toList();
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _mainImage == null) {
      if (_mainImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Please select a main image'),
              ],
            ),
            backgroundColor: const Color(0xFFFF4757),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final success = await postProvider.createPost(
      mainImageFile: _mainImage!,
      brandName: _brandController.text.trim(),
      sneakerName: _sneakerController.text.trim(),
      description: _descriptionController.text.trim(),
      additionalImageFiles: _additionalImages.isNotEmpty
          ? _additionalImages
          : null,
      purchaseLink: _purchaseLinkController.text.trim().isNotEmpty
          ? _purchaseLinkController.text.trim()
          : null,
      purchaseAddress: _purchaseAddressController.text.trim().isNotEmpty
          ? _purchaseAddressController.text.trim()
          : null,
      price: _priceController.text.trim().isNotEmpty
          ? double.tryParse(_priceController.text.trim())
          : null,
      year: _yearController.text.trim().isNotEmpty
          ? int.tryParse(_yearController.text.trim())
          : null,
    );

    if (success && mounted) {
      // Clear form
      _formKey.currentState!.reset();
      setState(() {
        _mainImage = null;
        _additionalImages = [];
      });
      _brandController.clear();
      _sneakerController.clear();
      _descriptionController.clear();
      _purchaseLinkController.clear();
      _purchaseAddressController.clear();
      _priceController.clear();
      _yearController.clear();
      _releaseDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Post created successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF00F5FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
            ),
          ),
          child: ResponsiveContainer(
            child: ResponsivePadding(
              child: Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 80),
                      children: [
                        // _buildHeaderSection(),
                        // const SizedBox(height: 24),
                        _buildMainImageSection(),
                        const SizedBox(height: 20),
                        _buildAdditionalImagesSection(),
                        const SizedBox(height: 20),
                        _buildSneakerDetailsSection(),
                        const SizedBox(height: 20),
                        _buildOptionalDetailsSection(),
                        if (postProvider.error != null) ...[
                          const SizedBox(height: 20),
                          _buildErrorMessage(postProvider.error!),
                        ],
                        const SizedBox(height: 75), // Adjusted for 65px nav
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        // child: _buildSubmitFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.9),
      elevation: 0,
      toolbarHeight: 65,
      // leading: Container(
      //   margin: const EdgeInsets.only(left: 16, top: 10, bottom: 3),
      //   // decoration: BoxDecoration(
      //   //   color: const Color(0xFF1A1A1A).withOpacity(0.8),
      //   //   borderRadius: BorderRadius.circular(12),
      //   //   border: Border.all(color: const Color(0xFF333333), width: 1),
      //   // ),
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back_ios_new_rounded,
      //       color: Colors.white,
      //       size: 20,
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      title: Container(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(6),
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
            //     ),
            //     boxShadow: [
            //       BoxShadow(
            //         color: const Color(0xFF00F5FF).withOpacity(0.3),
            //         blurRadius: 8,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: const Icon(
            //     Icons.add_a_photo_rounded,
            //     color: Colors.white,
            //     size: 16,
            //   ),
            // ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
              ).createShader(bounds),
              child: const Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 5, bottom: 5),
          child: Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: postProvider.isLoading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                        ),
                  color: postProvider.isLoading
                      ? const Color(0xFF2A2A2A)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: postProvider.isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: TextButton(
                  onPressed: postProvider.isLoading ? null : _submitPost,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 1,
                      bottom: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: postProvider.isLoading
                      ? const SizedBox(
                          width: 160,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white54,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/icon_sent3.png',
                              width: 22,
                              height: 22,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildHeaderSection() {
  //   return ScaleTransition(
  //     scale: _scaleAnimation,
  //     child: Container(
  //       padding: const EdgeInsets.all(24),
  //       margin: const EdgeInsets.symmetric(horizontal: 4),
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
  //         ),
  //         borderRadius: BorderRadius.circular(20),
  //         border: Border.all(
  //           color: const Color(0xFF00F5FF).withOpacity(0.3),
  //           width: 1,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF00F5FF).withOpacity(0.1),
  //             blurRadius: 20,
  //             offset: const Offset(0, 8),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               gradient: const LinearGradient(
  //                 colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: const Color(0xFF00F5FF).withOpacity(0.4),
  //                   blurRadius: 15,
  //                   offset: const Offset(0, 5),
  //                 ),
  //               ],
  //             ),
  //             child: const Icon(
  //               Icons.sports_baseball,
  //               color: Colors.white,
  //               size: 32,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           const Text(
  //             'Drop Your Heat',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 24,
  //               fontWeight: FontWeight.w900,
  //               letterSpacing: -0.5,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           const Text(
  //             'Share your sneaker collection with the community',
  //             style: TextStyle(
  //               color: Colors.white70,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMainImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    color: Color(0xFF00F5FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Main Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'REQUIRED',
                    style: TextStyle(
                      color: Color(0xFFFF4757),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickMainImage,
              child: Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _mainImage != null
                        ? const Color(0xFF00F5FF).withOpacity(0.5)
                        : const Color(0xFF404040).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: _mainImage != null
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: _mainImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _mainImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F5FF).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              size: 40,
                              color: Color(0xFF00F5FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tap to add your fire pic',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Show off those kicks!',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalImagesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFF00F5FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'More Angles',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: _pickAdditionalImages,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Add Photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_additionalImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _additionalImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF00F5FF).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00F5FF,
                                  ).withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _additionalImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _additionalImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4757),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF404040).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Add multiple angles to showcase your sneakers better',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSneakerDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
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
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          left: 12,
          right: 12,
          bottom: 12,
        ),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGlassTextField(
              controller: _brandController,
              label: 'Brand Name',
              icon: Icons.branding_watermark_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the brand name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _sneakerController,
              label: 'Sneaker Name',
              icon: Icons.sports_baseball_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the sneaker name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_rounded,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
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
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 15,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF00F5FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Optional Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGlassTextField(
              controller: _releaseDateController,
              label: 'Release Date',
              icon: Icons.calendar_today_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the release date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildGlassTextField(
              controller: _priceController,
              label: 'Price',
              icon: Icons.attach_money_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the price';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF404040).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00F5FF), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF4757), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF4757), width: 2),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFFF4757),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF4757).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF4757),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFFF4757),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSubmitFAB() {
  //   return Consumer<PostProvider>(
  //     builder: (context, postProvider, child) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           gradient: postProvider.isLoading
  //               ? null
  //               : const LinearGradient(
  //                   colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
  //                 ),
  //           color: postProvider.isLoading ? const Color(0xFF2A2A2A) : null,
  //           borderRadius: BorderRadius.circular(30),
  //           boxShadow: postProvider.isLoading
  //               ? null
  //               : [
  //                   BoxShadow(
  //                     color: const Color(0xFF00F5FF).withOpacity(0.4),
  //                     blurRadius: 20,
  //                     offset: const Offset(0, 8),
  //                   ),
  //                 ],
  //         ),
  //         child: FloatingActionButton.extended(
  //           onPressed: postProvider.isLoading ? null : _submitPost,
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           label: postProvider.isLoading
  //               ? Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const SizedBox(
  //                       width: 20,
  //                       height: 20,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         valueColor: AlwaysStoppedAnimation<Color>(
  //                           Colors.white54,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Creating...',
  //                       style: TextStyle(
  //                         color: Colors.white54,
  //                         fontWeight: FontWeight.w700,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ],
  //                 )
  //               : Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Icon(
  //                       Icons.send_rounded,
  //                       color: Colors.white,
  //                       size: 20,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     const Text(
  //                       'Share Your Heat',
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.w700,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
