import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<User?> signInWithGoogle() async {
    try {
      // Always show Google account picker
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Sign Up with email & password
  static Future<dynamic> signUp(String email, String password) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential.user; // Success: returns User object
    } on FirebaseAuthException catch (e) {
      print('Sign Up Error: ${e.code}, ${e.message}');
      return e.message; // Return Firebase error string to UI
    } catch (e) {
      print('Sign Up Unknown Error: $e');
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign In with email & password
  static Future<dynamic> signIn(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user; // Success: returns User object
    } on FirebaseAuthException catch (e) {
      print('Sign In Error: ${e.code}, ${e.message}');
      return e.message; // Return Firebase error string to UI
    } catch (e) {
      print('Sign In Unknown Error: $e');
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign Out (includes Google)
  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
