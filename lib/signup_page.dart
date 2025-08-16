import 'package:flutter/material.dart';
import 'package:water_bottle/services/firebase_auth_service.dart';
import 'package:water_bottle/services/supabase_data_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final SupabaseDataService _dataService = SupabaseDataService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
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
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (userCredential != null && mounted) {
        // Initialize user profile in Supabase with the full name
        try {
          await _dataService.createOrUpdateUserProfile(
            displayName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
          );
        } catch (e) {
          // Continue anyway - the user can still use the app
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header with back button and title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    // Back button (Arrow Left icon)
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
                          Icons.arrow_back,
                          color: Color(0xFF111518),
                          size: 24,
                        ),
                      ),
                    ),

                    // Title
                    Expanded(
                      child: Text(
                        'Create Account',
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

              const SizedBox(height: 20),

              // Full Name input field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextField(
                  controller: _fullNameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
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

              // Email input field
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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

              // Create Account button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.015,
                              ),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Bottom section with login link
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: const Color(0xFF637988),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          _isLoading
                              ? null
                              : () {
                                // Navigate back to intro page
                                Navigator.of(context).pop();
                              },
                      child: Text(
                        'Log In',
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

              // Bottom spacing for keyboard
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
