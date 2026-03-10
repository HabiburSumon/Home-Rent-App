import 'package:agentic_ai/app/features/authentication/presentation/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:agentic_ai/app/features/home/presentation/pages/home_page.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_service.dart';
import '../../data/repositories/shared_prefs_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ui.Image? _image;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: -500,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat(reverse: true);
    _loadImage();
  }

  // Load image from assets or network
  Future<void> _loadImage() async {
    try {
      // Option 1: Load from assets (recommended)
      // Make sure to add the image in pubspec.yaml under assets
      final ByteData data = await rootBundle.load('assets/images/giphy.jpg');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      setState(() {
        _image = frame.image;
      });
    } catch (e) {
      // Option 2: If asset fails, load from network as fallback
      _loadNetworkImage();
    }
  }

  // Alternative: Load from network
  Future<void> _loadNetworkImage() async {
    try {
      final imageUrl = 'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMmFkcWJid2tuZ2puMDgzYTg0OXlrc2tscDlnMXVkNnRveXplcTd4eSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/sFMuudjB6FgoU/giphy.gif';
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      final codec = await ui.instantiateImageCodec(response.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      setState(() {
        _image = frame.image;
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _image?.dispose();
    super.dispose();
  }


// ... Your existing login page code ...

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String emailOrPhone = _emailController.text.trim();
        final String password = _passwordController.text;

        // AuthService now handles token saving automatically
        final loginResponse = await AuthService.login(
          emailOrPhone: emailOrPhone,
          password: password,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate after SnackBar is done
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

// ... Rest of your login page code ...


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Title with Image
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      if (_image == null) {
                        // Fallback to gradient while image loads
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: const [
                                Colors.cyan,
                                Colors.blue,
                                Colors.purple,
                                Colors.pink,
                                Colors.orange,
                                Colors.yellow,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'WELCOME',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      }

                      // Use actual image for animation
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return ImageShader(
                            _image!,
                            TileMode.repeated,
                            TileMode.repeated,
                            Matrix4.translationValues(
                              _animation.value,
                              0,
                              0,
                            ).storage,
                          );
                        },
                        child: const Text(
                          'WELCOME',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Forgot password clicked'),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.blue.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Social Login Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  icon: Icons.g_mobiledata,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  icon: Icons.facebook,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 16),
                                _SocialButton(
                                  icon: Icons.apple,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }
}