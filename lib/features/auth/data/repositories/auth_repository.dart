import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // We pass the Web Client ID explicitly as serverClientId.
    // This is required on Android/Web to get the idToken for Firebase.
    serverClientId: '1016985675104-b6poh9slf440ioc9a469tuscflsicmvq.apps.googleusercontent.com',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserEntity?> signInWithGoogle({bool isRegister = false}) async {
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
    } catch (e, stack) {
      debugPrint('GOOGLE SIGN IN ERROR: $e\n$stack');
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

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    Function(PhoneAuthCredential credential)? onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        if (onVerificationCompleted != null) {
          onVerificationCompleted(credential);
        }
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserEntity> verifySmsCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final user = _auth.currentUser;
      if (user != null) {
        // Ensure not already linked
        bool isLinked = user.providerData.any((userInfo) => userInfo.providerId == 'phone');
        if (!isLinked) {
          await user.linkWithCredential(credential);
        }
        
        await _firestore.collection('users').doc(user.uid).update({
          'isPhoneVerified': true,
        });

        final doc = await _firestore.collection('users').doc(user.uid).get();
        return UserEntity.fromJson(doc.data()!);
      } else {
        throw Exception("Usuario no autenticado");
      }
    } catch (e) {
      throw Exception("Error verificando código SMS: $e");
    }
  }
}
