import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserEntity?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final User? user = userCredential.user;
        if (user != null) {
          return await _getUserEntityFromFirestore(user);
        }
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        
        if (user != null) {
          return await _getUserEntityFromFirestore(user);
        }
      }
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }
    return null;
  }

  Future<UserEntity> _getUserEntityFromFirestore(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    
    if (doc.exists) {
      // User exists, return the entity
      return UserEntity.fromJson(doc.data()!);
    } else {
      // New user, create with 'unassigned' role
      final newUser = UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Usuario',
        photoUrl: user.photoURL ?? '',
        role: 'unassigned',
        isPhoneVerified: false,
      );
      
      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
      return newUser;
    }
  }

  Future<UserEntity> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserEntity.fromJson(doc.data()!);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
