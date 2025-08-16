import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_bottle/home_page.dart';
import 'package:water_bottle/intro_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Wait a bit for Firebase to initialize completely
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current user immediately
      final user = FirebaseAuth.instance.currentUser;

      // Check if user is actually authenticated
      if (user != null) {
        try {
          // Verify the user token is still valid
          await user.getIdToken(true);
        } catch (e) {
          // Sign out the user if token is invalid
          await FirebaseAuth.instance.signOut();
          setState(() {
            _currentUser = null;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      // Also listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF42AAF0)),
        ),
      );
    }

    // If user is logged in, go to home page
    if (_currentUser != null) {
      return const HomePage();
    }

    // If user is not logged in, show intro page
    return const IntroPage();
  }
}
