import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    // 🔥 IMPORTANT: persistence fix (web + mobile)
    _auth.setPersistence(Persistence.LOCAL);
  }

  // =====================================================
  // SIGN UP
  // =====================================================
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    final userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCredential.user;

    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": email.trim(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  // =====================================================
  // LOGIN (FIXED)
  // =====================================================
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // =====================================================
  // LOGOUT (FIXED)
  // =====================================================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =====================================================
  // AUTO LOGIN STREAM
  // =====================================================
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
