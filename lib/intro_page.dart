import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with background image and text
            Expanded(
              child: Column(
                children: [
                  // Background image container
                  Container(
                    width: double.infinity,
                    height: 320,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBSEBkWWTv-fUpDZ-hewD4SFn9WzmTu9dQXMtA1YpJYIcocjJqPjQFAaKAG5mP-eNskDCuaumNfpj29djGOzLOE918lKQLorVsd2wp1EEIzD38frHZ4mYKJ83sIJua7zg-NEX82KyrHCYpclrI7t7AQ5S60UrZMSOgIuakfTvSzXw5eWdKvOfiPNmhKu0utlD79OheGYBp3RirZIJ5Mygh2imaRxiKuwzqUnqBAQBKWnRUKJIyjLRcqzDVjxCOppAVa3rLZjlRomJI',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Track your water fetching',
                      style: TextStyle(
                        color: const Color(0xFF111518),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Join the community and track your water fetching activities',
                      style: TextStyle(
                        color: const Color(0xFF617989),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42AAF0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF42AAF0),
                        side: const BorderSide(
                          color: Color(0xFF42AAF0),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
