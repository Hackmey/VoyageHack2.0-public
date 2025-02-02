import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return e.toString(); // Error message
    }
  }

  // Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } catch (e) {
      return e.toString(); // Error message
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
