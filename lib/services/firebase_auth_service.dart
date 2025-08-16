import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get all users from database (excluding current user)
  // TODO: Replace with actual Firestore call when firebase_firestore is added
  Future<List<String>> getAllUsersExceptCurrent() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // For now, we'll use Firebase Auth to get user information
      // This is a temporary solution until Firestore is added

      // Get current user's display name
      final currentUserName = currentUser.displayName ?? 'Current User';

      // Since we don't have Firestore yet, we can only show the current user
      // In a real app with Firestore, you'd query all users from the database

      // For now, return empty list since we can't access other users without Firestore
      // This will show "No users available" in the dropdown
      return [];

      // TODO: When firebase_firestore is added, implement this:
      // final usersSnapshot = await _firestore.collection('users').get();
      // List<String> userNames = [];
      // for (var doc in usersSnapshot.docs) {
      //   final userData = doc.data();
      //   final userName = userData['fullName'] ?? userData['displayName'] ?? 'Unknown User';
      //   if (doc.id != currentUser.uid) {
      //     userNames.add(userName);
      //   }
      // }
      // return userNames;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Create multiple users with specified names (for development/testing)
  // This creates real Firebase Auth accounts
  Future<List<String>> createMultipleUsers({
    required List<String> names,
    required String defaultPassword,
  }) async {
    List<String> createdUsers = [];

    for (String name in names) {
      try {
        // Block placeholder names
        if (_isBlockedName(name)) {
          print('Skipping blocked name: $name');
          continue;
        }

        // Create a unique email for each user
        String email =
            '${name.toLowerCase().replaceAll(' ', '')}@waterbottle.com';

        // Create user account
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: email,
              password: defaultPassword,
            );

        // Update display name
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(name);
          createdUsers.add(name);
          print('Created user: $name with email: $email');
        }
      } catch (e) {
        print('Error creating user $name: $e');
        // Continue with other users even if one fails
      }
    }

    return createdUsers;
  }

  // Check if a name is blocked
  bool _isBlockedName(String name) {
    final blockedNames = [
      'john doe',
      'jane smith',
      'john smith',
      'jane doe',
      'test user',
      'sample user',
      'demo user',
      'example user',
    ];
    return blockedNames.contains(name.toLowerCase());
  }

  // Get current user's profile information
  Map<String, dynamic>? getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
    };
  }

  // Ensure user profile exists in Supabase (for existing users)
  Future<void> ensureUserProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final client = Supabase.instance.client;

      // Check if profile exists
      final response =
          await client
              .from('user_profiles')
              .select()
              .eq('firebase_uid', user.uid)
              .maybeSingle();

      // If no profile exists, create one
      if (response == null) {
        print('🔄 Creating missing user profile for: ${user.email}');
        await _createUserProfileInSupabase(
          firebaseUid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Unknown User',
        );
      } else {
        print('✅ User profile already exists for: ${user.email}');
        // Update existing profile with current Firebase data
        await client
            .from('user_profiles')
            .update({
              'display_name': user.displayName ?? response['display_name'],
              'email': user.email ?? response['email'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('firebase_uid', user.uid);
        print('✅ User profile updated for: ${user.email}');
      }
    } catch (e) {
      print('❌ Error ensuring user profile exists: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Block placeholder names
      if (fullName != null && _isBlockedName(fullName)) {
        throw Exception('This name is not allowed. Please use your real name.');
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name if provided
      if (fullName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);

        // Create user profile in Supabase
        try {
          await _createUserProfileInSupabase(
            firebaseUid: userCredential.user!.uid,
            email: email,
            displayName: fullName,
          );
        } catch (e) {
          // If profile creation fails, try to ensure it exists
          await ensureUserProfileExists();
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user profile exists in Supabase after successful login
      if (userCredential.user != null) {
        await ensureUserProfileExists();
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user profile in Supabase
  Future<void> _createUserProfileInSupabase({
    required String firebaseUid,
    required String email,
    required String displayName,
  }) async {
    try {
      final client = Supabase.instance.client;

      // Check if profile already exists
      final existingProfile =
          await client
              .from('user_profiles')
              .select()
              .eq('firebase_uid', firebaseUid)
              .maybeSingle();

      if (existingProfile == null) {
        // Create new profile
        await client.from('user_profiles').insert({
          'firebase_uid': firebaseUid,
          'display_name': displayName,
          'email': email,
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ User profile created successfully for: $email');
      } else {
        // Update existing profile
        await client
            .from('user_profiles')
            .update({
              'display_name': displayName,
              'email': email,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('firebase_uid', firebaseUid);
        print('✅ User profile updated successfully for: $email');
      }
    } catch (e) {
      print('❌ Error creating/updating user profile: $e');
      // Don't throw here - we want the signup to succeed even if profile creation fails
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
