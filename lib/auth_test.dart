import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_bottle/services/firebase_auth_service.dart';
import 'package:water_bottle/services/supabase_data_service.dart';

class AuthTest extends StatefulWidget {
  const AuthTest({super.key});

  @override
  State<AuthTest> createState() => _AuthTestState();
}

class _AuthTestState extends State<AuthTest> {
  String _authStatus = 'Checking...';
  User? _currentUser;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final SupabaseDataService _dataService = SupabaseDataService();

  // Test credentials
  final TextEditingController _testEmailController = TextEditingController();
  final TextEditingController _testPasswordController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _testEmailController.text =
        'test${DateTime.now().millisecondsSinceEpoch}@example.com';
    _testPasswordController.text = 'testpass123';
    _testNameController.text =
        'Test User ${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _testEmailController.dispose();
    _testPasswordController.dispose();
    _testNameController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Wait for Firebase to be ready
      await Future.delayed(const Duration(seconds: 1));

      final user = FirebaseAuth.instance.currentUser;
      print('AuthTest - Current user: ${user?.email} (${user?.uid})');

      if (user != null) {
        try {
          final token = await user.getIdToken(true);
          print('AuthTest - Token obtained: ${token?.substring(0, 20)}...');
          setState(() {
            _authStatus = 'User logged in: ${user.email}';
            _currentUser = user;
          });
        } catch (e) {
          print('AuthTest - Token error: $e');
          setState(() {
            _authStatus = 'Token error: $e';
          });
        }
      } else {
        setState(() {
          _authStatus = 'No user logged in';
        });
      }
    } catch (e) {
      print('AuthTest - Error: $e');
      setState(() {
        _authStatus = 'Error: $e';
      });
    }
  }

  Future<void> _testSignUp() async {
    try {
      setState(() {
        _authStatus = 'Testing signup...';
      });

      print('Testing signup with: ${_testEmailController.text}');

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: _testEmailController.text,
        password: _testPasswordController.text,
        fullName: _testNameController.text,
      );

      if (userCredential != null) {
        setState(() {
          _authStatus =
              'Signup successful! User: ${userCredential.user?.email}';
          _currentUser = userCredential.user;
        });
        print('Signup test successful');
      } else {
        setState(() {
          _authStatus = 'Signup failed - no user credential returned';
        });
        print('Signup test failed - no user credential');
      }
    } catch (e) {
      print('Signup test error: $e');
      setState(() {
        _authStatus = 'Signup error: $e';
      });
    }
  }

  Future<void> _testSignIn() async {
    try {
      setState(() {
        _authStatus = 'Testing signin...';
      });

      print('Testing signin with: ${_testEmailController.text}');

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _testEmailController.text,
        password: _testPasswordController.text,
      );

      if (userCredential != null) {
        setState(() {
          _authStatus =
              'Signin successful! User: ${userCredential.user?.email}';
          _currentUser = userCredential.user;
        });
        print('Signin test successful');
      } else {
        setState(() {
          _authStatus = 'Signin failed - no user credential returned';
        });
        print('Signin test failed - no user credential');
      }
    } catch (e) {
      print('Signin test error: $e');
      setState(() {
        _authStatus = 'Signin error: $e';
      });
    }
  }

  Future<void> _testSignOut() async {
    try {
      setState(() {
        _authStatus = 'Testing signout...';
      });

      print('Testing signout...');

      await _authService.signOut();

      setState(() {
        _authStatus = 'Signout successful!';
        _currentUser = null;
      });
      print('Signout test successful');
    } catch (e) {
      print('Signout test error: $e');
      setState(() {
        _authStatus = 'Signout error: $e';
      });
    }
  }

  Future<void> _testProfileCreation() async {
    try {
      if (_currentUser == null) {
        setState(() {
          _authStatus = 'No user to test profile creation';
        });
        return;
      }

      setState(() {
        _authStatus = 'Testing profile creation...';
      });

      print('Testing profile creation for: ${_currentUser!.email}');

      await _dataService.createOrUpdateUserProfile(
        displayName: _testNameController.text,
        email: _currentUser!.email,
      );

      setState(() {
        _authStatus = 'Profile creation successful!';
      });
      print('Profile creation test successful');
    } catch (e) {
      print('Profile creation test error: $e');
      setState(() {
        _authStatus = 'Profile creation error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
        backgroundColor: const Color(0xFF42AAF0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication Status:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(_authStatus),
            const SizedBox(height: 16),

            if (_currentUser != null) ...[
              Text('User ID: ${_currentUser!.uid}'),
              Text('Email: ${_currentUser!.email}'),
              Text('Display Name: ${_currentUser!.displayName ?? 'None'}'),
              const SizedBox(height: 16),
            ],

            // Test credentials
            Text(
              'Test Credentials:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _testEmailController,
              decoration: const InputDecoration(
                labelText: 'Test Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _testPasswordController,
              decoration: const InputDecoration(
                labelText: 'Test Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _testNameController,
              decoration: const InputDecoration(
                labelText: 'Test Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSignUp,
                    child: const Text('Test Signup'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSignIn,
                    child: const Text('Test Signin'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testSignOut,
                    child: const Text('Test Signout'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testProfileCreation,
                    child: const Text('Test Profile'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _checkAuthStatus,
              child: const Text('Refresh Auth Status'),
            ),
          ],
        ),
      ),
    );
  }
}
