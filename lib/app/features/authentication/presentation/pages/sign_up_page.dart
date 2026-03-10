import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../../data/repositories/auth_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ui.Image? _image;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: -500).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.repeat(reverse: true);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/giphy.jpg');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _image = frame.image;
        });
      }
    } catch (e) {
      _loadNetworkImage();
    }
  }

  Future<void> _loadNetworkImage() async {
    try {
      final imageUrl =
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMmFkcWJid2tuZ2puMDgzYTg0OXlrc2tscDlnMXVkNnRveXplcTd4eSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/sFMuudjB6FgoU/giphy.gif';
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      final codec = await ui.instantiateImageCodec(response.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _image = frame.image;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _image?.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // In _handleSignUp method:
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final signupResponse = await AuthService.signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (signupResponse.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(signupResponse.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Wait a bit for user to see the message
          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            // Navigate back to login page with success flag
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  // showSuccessMessage: true,
                  // successMessage: 'Account created successfully! Please login.',
                ),

              ),
            );
          }
        } else {
          // Show error message from server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(signupResponse.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                  // Animated Title
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      if (_image == null) {
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
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
                          ).createShader(bounds),
                          child: const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      }

                      return ShaderMask(
                        shaderCallback: (bounds) => ImageShader(
                          _image!,
                          TileMode.repeated,
                          TileMode.repeated,
                          Matrix4.translationValues(_animation.value, 0, 0).storage,
                        ),
                        child: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 52,
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
                    'Join us today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Sign Up Form Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (value.length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
// Phone Number with Country Code
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70),
                                prefixText: '+234  ', // Change to your default country code
                                prefixStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter phone number';
                                if (value.length < 9 || value.length > 15) return 'Invalid phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password
                            TextFormField(
                              controller: _confirmPasswordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Sign Up Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text(
                                'SIGN UP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Social Sign Up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(icon: Icons.g_mobiledata, onPressed: () {}),
                                const SizedBox(width: 16),
                                _SocialButton(icon: Icons.facebook, onPressed: () {}),
                                const SizedBox(width: 16),
                                _SocialButton(icon: Icons.apple, onPressed: () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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

// Reusable Social Button (same as LoginPage)
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }
}