import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_background/animated_background.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late PageController controller;
  bool isLastPage = false;
  late AnimationController _animationController;
  late AnimationController _bounceController;
  late AnimationController _perspective3DController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  final List<List<Color>> _gradients = [
    [
      const Color(0xFF000000), // Pure black
      const Color(0xFF1A1A1A), // Dark charcoal
      const Color(0xFF333333), // Rich gray
    ],
    [
      const Color(0xFF0A0A0A), // Almost black
      const Color(0xFF242424), // Deep charcoal
      const Color(0xFF404040), // Medium gray
    ],
    [
      const Color(0xFF121212), // Material dark
      const Color(0xFF2C2C2C), // Dark slate
      const Color(0xFF484848), // Graphite
    ],
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _perspective3DController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    _bounceController.dispose();
    _perspective3DController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    // Navigate back to root so AuthWrapper can handle the flow
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            spawnMaxRadius: 15,
            spawnMinRadius: 5,
            particleCount: 40,
            spawnMinSpeed: 50.0,
            spawnMaxSpeed: 100.0,
            minOpacity: 0.1,
            maxOpacity: 0.3,
            baseColor: Colors.white, // Keep white particles for contrast
          ),
        ),
        vsync: this,
        child: TweenAnimationBuilder(
          tween: ColorTween(
            begin: _gradients[_currentPage][0],
            end: _gradients[_currentPage][1],
          ),
          duration: const Duration(
            milliseconds: 1000,
          ), // Faster color transition
          curve: Curves.easeInOut, // Smoother curve
          builder: (context, Color? color, Widget? child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color ?? _gradients[_currentPage][0],
                    _gradients[_currentPage][1],
                    _gradients[_currentPage][2],
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: GradientRotation(
                    (DateTime.now().millisecondsSinceEpoch / 5000) *
                        2 *
                        3.14159,
                  ),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: controller,
                      onPageChanged: (index) {
                        setState(() {
                          isLastPage = index == 2;
                          _currentPage = index;
                        });
                      },
                      physics:
                          const CustomPageViewScrollPhysics(), // Add custom physics
                      itemCount: 3,
                      itemBuilder: (context, index) => _buildIntroPage(
                        index == 0
                            ? 'Share Your Collection'
                            : index == 1
                            ? 'Rate & Be Rated'
                            : 'Reach the Top 10',
                        index == 0
                            ? 'Showcase your best sneakers to a community of enthusiasts'
                            : index == 1
                            ? 'Vote on other collectors\' sneakers and receive feedback on yours'
                            : 'The highest-rated sneakers get featured on our leaderboard',
                        index == 0
                            ? 'assets/animations/sneaker_animation3.json'
                            : index == 1
                            ? 'assets/animations/sneaker_animation3.json'
                            : 'assets/animations/sneaker_animation3.json',
                      ),
                    ),
                    // Animated shapes in background
                    ..._buildAnimatedShapes(),
                    // App title at top
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child:
                              Column(
                                    children: [
                                      Text(
                                        'theSoleHead',
                                        style: GoogleFonts.barrio(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                          height: 1.2,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10.0,
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              offset: const Offset(2.0, 2.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        'Rate, Share, Compete',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .shimmer(duration: 1800.ms, delay: 1000.ms)
                                  .then()
                                  .fadeIn(duration: 600.ms),
                        ),
                      ),
                    ),
                    // Page indicators and buttons
                    Container(
                      alignment: const Alignment(0, 0.85),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Skip button
                          if (!isLastPage)
                            TextButton(
                                  onPressed: () => controller.jumpToPage(2),
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 300.ms)
                                .moveX(begin: -30, end: 0),
                          // Dot indicators
                          SmoothPageIndicator(
                                controller: controller,
                                count: 3,
                                effect: CustomizableEffect(
                                  activeDotDecoration: DotDecoration(
                                    width: 32,
                                    height: 8,
                                    color: Colors.white,
                                    rotationAngle: 0,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  dotDecoration: DotDecoration(
                                    width: 8,
                                    height: 8,
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  spacing: 8,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 800.ms, delay: 500.ms)
                              .scaleXY(begin: 0.5, end: 1.0),
                          // Next/Done button
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.2, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                            child: isLastPage
                                ? ElevatedButton(
                                        key: const ValueKey('getStarted'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor:
                                              _gradients[_currentPage][0],
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          _handleGetStarted();
                                        },
                                        child: const Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(reverse: true),
                                      )
                                      .scaleXY(end: 1.05, duration: 1000.ms)
                                : TextButton(
                                        key: const ValueKey('next'),
                                        onPressed: () {
                                          controller.nextPage(
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Next',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(duration: 500.ms, delay: 300.ms)
                                      .moveX(begin: 30, end: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroPage(
    String title,
    String description,
    String animationPath,
  ) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sneaker animation using Lottie
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Lottie.asset(
                animationPath,
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                reverse: false,
                options: LottieOptions(enableMergePaths: true),
                onLoaded: (composition) {
                  // Animation loaded successfully
                },
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if animation fails to load
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.sports_handball,
                      size: 100,
                      color: Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Enhanced title with better typography
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                Text(
                      title,
                      key: ValueKey(title),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.spaceMono().fontFamily,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0)
                    .then()
                    .shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withOpacity(0.8),
                    ),
          ),
          const SizedBox(height: 24),
          // Enhanced description with better typography
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                Text(
                      description,
                      key: ValueKey(description),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontFamily: GoogleFonts.raleway().fontFamily,
                        letterSpacing: 0.5,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0)
                    .then()
                    .shimmer(
                      duration: 2000.ms,
                      delay: 1000.ms,
                      color: Colors.white.withOpacity(0.5),
                    ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedShapes() {
    return [
      Positioned(
        top: 100,
        right: 20,
        child: _buildAnimatedShape(
          size: 60,
          color: Colors.white.withOpacity(0.15),
          borderRadius: 8,
          rotationSpeed: 15000,
        ),
      ),
      Positioned(
        bottom: 150,
        left: 30,
        child: _buildAnimatedShape(
          size: 40,
          color: Colors.white.withOpacity(0.1),
          borderRadius: 20,
          rotationSpeed: 12000,
        ),
      ),
      // ...existing positioned widgets...
    ];
  }

  Widget _buildAnimatedShape({
    required double size,
    required Color color,
    required double borderRadius,
    required int rotationSpeed,
  }) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // Subtle white shapes
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1), // Subtle border
              width: 1,
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: Duration(milliseconds: rotationSpeed), end: 2)
        .fadeIn(duration: 600.ms)
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          curve: Curves.elasticOut,
          duration: 1200.ms,
        );
  }
}

// Dummy home page for navigation
class DummyHomePage extends StatelessWidget {
  const DummyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SneakerSpot', // Changed from SneakerVote
          style: GoogleFonts.permanentMarker(),
        ),
        backgroundColor: const Color(0xFF1a1c20),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1c20), Color(0xFF5c2a9d), Color(0xFF2d00f7)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 24),
              Text(
                'Coming Soon!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.spaceMono().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re working hard to bring you\nthe best sneaker rating experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
        ),
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 80, // Heavier mass for smoother motion
    stiffness: 100, // Lower stiffness for less resistance
    damping: 1.0, // Perfect damping
  );
}
