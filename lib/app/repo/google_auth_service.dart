import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleAuthProvider authProvider = GoogleAuthProvider();
    return _auth.signInWithPopup(authProvider);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
