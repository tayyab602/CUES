import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Get ID token for backend calls
  Future<String?> getToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  // REGISTER
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String department,
    required String semester,
    required String searchTag, //  FIXED: Parameter added to accept the unique Discord-style tag
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user to Firestore
    await _db.collection("users").doc(credential.user!.uid).set({
      "uid": credential.user!.uid,
      "name": name,
      "email": email,
      "campusId": email.split('@')[0].toUpperCase(), // Generated shorthand ID
      "searchTag": searchTag.toLowerCase(), // Saved in lowercase for foolproof searching
      "profilePicUrl": "", // Initialize as empty string to prevent null pointer errors later
      "department": department,
      "semester": semester,
      "role": "student",
      "createdAt": DateTime.now().toIso8601String(),
    });

    return credential;
  }

  // LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}