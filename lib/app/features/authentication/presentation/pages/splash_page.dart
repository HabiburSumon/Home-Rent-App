import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';
// import 'package:agentic_ai/app/features/authentication/presentation/pages/login_page.dart';
// import 'package:agentic_ai/app/features/home/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  final bool _isLoggedIn = false; // Simulate auth status

  late AnimationController _textAnimationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  late Animation<double> _textAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  ui.Image? _image;

  @override
  void initState() {
    super.initState();

    // Text shimmer animation (for image effect)
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _textAnimation = Tween<double>(
      begin: 0,
      end: -500,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    _shimmerController.repeat(reverse: true);

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    // Load image for text effect
    _loadImage();

    // Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _loadImage() async {
    try {
      // Try loading from assets first
      final ByteData data = await rootBundle.load('assets/images/giphy.jpg');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _image = frame.image;
        });
      }
    } catch (e) {
      // If asset loading fails, continue without image
      print('Could not load image: $e');
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Fade out animation before navigation
    await _fadeController.reverse();

    if (!mounted) return;

    // Uncomment these when you have the actual pages
    if (_isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo/Icon (you can replace with your logo)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Animated Title with Image/Gradient
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        if (_image != null) {
                          // Use image shader if available
                          return ImageShader(
                            _image!,
                            TileMode.repeated,
                            TileMode.repeated,
                            Matrix4.translationValues(
                              _textAnimation.value,
                              0,
                              0,
                            ).storage,
                          );
                        } else {
                          // Fallback to animated gradient
                          return LinearGradient(
                            colors: const [
                              Colors.cyan,
                              Colors.blue,
                              Colors.purple,
                              Colors.pink,
                              Colors.orange,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            transform: GradientRotation(_textAnimation.value / 100),
                          ).createShader(
                            Rect.fromLTWH(
                              _textAnimation.value,
                              0,
                              bounds.width * 2,
                              bounds.height,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Home Rent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Subtitle with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Find Your Perfect Home',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                // Animated Loading Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating circle
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Inner progress indicator
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Loading text with pulse animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 2,
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
}

// Alternative: More elaborate animated splash
class ElaborateSplashPage extends StatefulWidget {
  const ElaborateSplashPage({super.key});

  @override
  State<ElaborateSplashPage> createState() => _ElaborateSplashPageState();
}

class _ElaborateSplashPageState extends State<ElaborateSplashPage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade800,
              Colors.pink.shade700,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background waves
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Positioned(
                    left: -100 + (_waveController.value * 200),
                    top: 100.0 + (index * 150),
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.home_rounded,
                        size: 200,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            size: 80,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Home Rent App',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 100),
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}