import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  Map<String, dynamic>? _userProfile;
  double _totalPoints = 0.0;
  int _verifiedPosts = 0;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _ensureUserProfileExists();
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when page becomes visible
    _loadUserProfile();
  }

  Future<void> _ensureUserProfileExists() async {
    if (_user == null) return;

    try {
      final client = Supabase.instance.client;

      // Check if profile exists
      final response =
          await client
              .from('user_profiles')
              .select()
              .eq('firebase_uid', _user!.uid)
              .maybeSingle();

      // If no profile exists, create one
      if (response == null) {
        await client.from('user_profiles').insert({
          'firebase_uid': _user!.uid,
          'display_name': _user!.displayName ?? 'Unknown User',
          'email': _user!.email ?? '',
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      final client = Supabase.instance.client;
      final response =
          await client
              .from('user_profiles')
              .select()
              .eq('firebase_uid', _user!.uid)
              .single();

      setState(() {
        _userProfile = response;
      });

      // Load user stats
      await _loadUserStats();
    } catch (e) {
      // Handle error silently for now
    }
  }

  String _getInitials(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return '?';
    }

    final names = displayName.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '?';
  }

  String _getDisplayName() {
    // Prioritize Firebase displayName (full name from signup) over Supabase
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    // Fallback to Supabase if Firebase doesn't have the name
    if (_userProfile != null && _userProfile!['display_name'] != null) {
      return _userProfile!['display_name'];
    }
    return 'Unknown User';
  }

  String _getUserEmail() {
    return _user?.email ?? 'No email available';
  }

  String? _getPhotoUrl() {
    if (_userProfile != null && _userProfile!['photo_url'] != null) {
      return _userProfile!['photo_url'];
    }
    return _user?.photoURL;
  }

  Future<void> _loadUserStats() async {
    if (_user == null) return;

    try {
      final client = Supabase.instance.client;
      double totalPoints = 0.0;
      int verifiedPosts = 0;

      // Get posts where user is the poster
      final postsAsPoster = await client
          .from('water_fetch_posts')
          .select('points, verification_status, fetch_type, partner_user_id')
          .eq('firebase_uid', _user!.uid);

      if (postsAsPoster != null) {
        for (final post in postsAsPoster) {
          if (post['verification_status'] == 'verified') {
            totalPoints += (post['points'] ?? 0.0).toDouble();
            verifiedPosts++;
          }
        }
      }

      // Get posts where user is the partner in Together mode
      final postsAsPartner = await client
          .from('water_fetch_posts')
          .select('verification_status, fetch_type, partner_user_id')
          .eq('partner_user_id', _getDisplayName())
          .eq('fetch_type', 'Together');

      if (postsAsPartner != null) {
        for (final post in postsAsPartner) {
          if (post['verification_status'] == 'verified') {
            // Partner gets 0.5 points for verified Together posts
            totalPoints += 0.5;
            verifiedPosts++;
          }
        }
      }

      setState(() {
        _totalPoints = totalPoints;
        _verifiedPosts = verifiedPosts;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // The AuthWrapper will automatically redirect to intro page
      // No need to navigate manually
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                  return;
                }

                try {
                  // Re-authenticate user before changing password
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: _user?.email ?? '',
                    password: currentPasswordController.text,
                  );
                  await _user?.reauthenticateWithCredential(credential);

                  // Change password
                  await _user?.updatePassword(newPasswordController.text);

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error changing password: $e')),
                    );
                  }
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profile',
                      style: const TextStyle(
                        color: Color(0xFF111518),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.015,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadUserProfile,
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFF111518),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture with Initials
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF42AAF0),
                    ),
                    child:
                        _getPhotoUrl() != null && _getPhotoUrl()!.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                _getPhotoUrl()!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildInitialsAvatar();
                                },
                              ),
                            )
                            : _buildInitialsAvatar(),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    _getDisplayName(),
                    style: const TextStyle(
                      color: Color(0xFF111518),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.015,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // User Email
                  Text(
                    _getUserEmail(),
                    style: const TextStyle(
                      color: Color(0xFF617989),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.2,
                      letterSpacing: -0.015,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // User Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Total Points
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF42AAF0),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _totalPoints.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Color(0xFF42AAF0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Points',
                                  style: TextStyle(
                                    color: Color(0xFF617989),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Verified Posts
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F8FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF42AAF0),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _verifiedPosts.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF42AAF0),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Posts',
                                  style: TextStyle(
                                    color: Color(0xFF617989),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Account Section
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account',
                  style: TextStyle(
                    color: Color(0xFF111518),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.015,
                  ),
                ),
              ),
            ),

            // Change Password Option
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showChangePasswordDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Change Password',
                            style: const TextStyle(
                              color: Color(0xFF111518),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF111518),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F3F4),
                    foregroundColor: const Color(0xFF111518),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.015,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _getInitials(_getDisplayName()),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F3F4), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Home tab
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.of(context).pushReplacementNamed('/home'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: const Color(0xFF637988),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: const TextStyle(
                          color: Color(0xFF637988),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Leaderboard tab
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/leaderboard'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        color: const Color(0xFF637988),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leaderboard',
                        style: const TextStyle(
                          color: Color(0xFF637988),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Profile tab (active)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      color: const Color(0xFF111518),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profile',
                      style: const TextStyle(
                        color: Color(0xFF111518),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.015,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
