// lib/core/services/google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> signInWithGoogle() async {
    try {
      // Sign out from current session to force account selection
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow with account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      // Get the ID token to send to your backend
      final String? idToken = await userCredential.user?.getIdToken();
      
      return idToken;
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Alternative method that shows account picker more explicitly
  Future<String?> signInWithGoogleAccountPicker() async {
    try {
      // Disconnect completely to ensure account picker shows
      await _googleSignIn.disconnect();
      
      // Configure GoogleSignIn to show account picker
      final GoogleSignIn googleSignInWithPicker = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // This will force the account selection dialog
      final GoogleSignInAccount? googleUser = await googleSignInWithPicker.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();
      
      return idToken;
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // Method to get previously signed in accounts (if available)
  Future<List<GoogleSignInAccount>> getPreviouslySignedInAccounts() async {
    try {
      // This might return cached accounts on some platforms
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        return [currentUser];
      }
      
      // Try to silently sign in to get cached accounts
      final GoogleSignInAccount? silentUser = await _googleSignIn.signInSilently();
      if (silentUser != null) {
        await _googleSignIn.signOut(); // Sign out after getting info
        return [silentUser];
      }
      
      return [];
    } catch (e) {
      print('Error getting previous accounts: $e');
      return [];
    }
  }

  // Method to force account selection dialog
  Future<String?> selectAccountAndSignIn() async {
    try {
      // Ensure we're signed out to force account picker
      await signOut();
      
      // Small delay to ensure sign out is complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sign in with account selection
      return await signInWithGoogle();
    } catch (e) {
      print('Account selection error: $e');
      throw Exception('Account selection failed: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Complete disconnect - removes all cached account info
  Future<void> disconnect() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.disconnect(),
    ]);
  }
}