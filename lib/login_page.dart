import 'package:flutter/material.dart';
import 'package:water_bottle/services/firebase_auth_service.dart';
import 'package:water_bottle/services/supabase_data_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final SupabaseDataService _dataService = SupabaseDataService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential != null && mounted) {
        // Sync user profile to Supabase if needed
        try {
          final user = userCredential.user;
          if (user != null) {
            await _dataService.createOrUpdateUserProfile(
              displayName:
                  user.displayName ?? 'User ${user.uid.substring(0, 8)}',
              email: user.email,
              photoURL: user.photoURL,
            );
          }
        } catch (e) {
          // Continue anyway - the user can still use the app
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );

        // Small delay to ensure auth state is updated, then navigate
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false, // Remove all previous routes
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with header and title
            Expanded(
              child: Column(
                children: [
                  // Header with back button and title
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Back button (X icon)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF111518),
                              size: 24,
                            ),
                          ),
                        ),

                        // Title
                        Expanded(
                          child: Text(
                            'Water Tracker',
                            style: TextStyle(
                              color: const Color(0xFF111518),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -0.015,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Spacer to balance the layout
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Welcome back title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          color: const Color(0xFF111518),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          letterSpacing: -0.015,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email input field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          color: Color(0xFF637988),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F3F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF111518),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  // Password input field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: TextField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          color: Color(0xFF637988),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F3F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF637988),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF111518),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1994E6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.015,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with sign up link
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  GestureDetector(
                    onTap:
                        _isLoading
                            ? null
                            : () {
                              // TODO: Navigate to sign up page
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sign up page coming soon!'),
                                ),
                              );
                            },
                    child: Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        color:
                            _isLoading
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF637988),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom spacing
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
