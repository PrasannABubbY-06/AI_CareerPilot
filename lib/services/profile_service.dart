import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<DocumentSnapshot> getUserData() {
    return _firestore.collection("users").doc(uid).get();
  }

  Future<void> updateProfile({
    required String name,
    required String photoUrl,
  }) async {
    await _firestore.collection("users").doc(uid).update({
      "name": name,
      "photoUrl": photoUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}