import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper around [FirebaseAuth] to simplify authentication operations.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Sign in with email and password.
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() => _auth.signOut();
}
