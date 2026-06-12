import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import 'package:unirent/core/network/api_client.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1046855873659-d6jqoih04jiakmli4ce02uegahva99r1.apps.googleusercontent.com',
    // We pass the Web Client ID explicitly as serverClientId.
    // This is required on Android/Web to get the idToken for Firebase.
    serverClientId: '1046855873659-d6jqoih04jiakmli4ce02uegahva99r1.apps.googleusercontent.com',
  );
  
  final ApiClient _apiClient = ApiClient();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserEntity?> signInWithGoogle({bool isRegister = false}) async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final User? user = userCredential.user;
        if (user != null) {
          return await getUserEntityFromBackend(user);
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
          return await getUserEntityFromBackend(user);
        }
      }
    } catch (e, stack) {
      debugPrint('GOOGLE SIGN IN ERROR: $e\n$stack');
      throw Exception('Error en Google Sign-In: $e');
    }
    return null;
  }

  Future<UserEntity> getUserEntityFromBackend(User user) async {
    // Send user to Spring Boot backend to sync DB
    final response = await _apiClient.post('/users/sync', {
      'uid': user.uid,
      'phoneNumber': user.phoneNumber ?? '',
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoUrl': user.photoURL ?? '',
    });
    
    return UserEntity(
      id: response['id'],
      email: user.email ?? '',
      name: user.displayName ?? 'Usuario',
      photoUrl: user.photoURL ?? '',
      role: response['role'] ?? 'unassigned',
      isPhoneVerified: response['phoneNumber'] != null && response['phoneNumber'].toString().isNotEmpty,
    );
  }

  Future<UserEntity> updateUserRole(String uid, String role) async {
    final response = await _apiClient.put('/users/$uid/role', {
      'role': role,
    });
    
    return UserEntity(
      id: response['id'],
      email: response['email'] ?? '', 
      name: response['displayName'] ?? 'Usuario',
      photoUrl: response['photoUrl'] ?? '',
      role: response['role'],
      isPhoneVerified: response['phoneNumber'] != null && response['phoneNumber'].toString().isNotEmpty,
    );
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
          await user.linkWithCredential(credential).timeout(const Duration(seconds: 15), onTimeout: () {
            throw Exception("Tiempo de espera agotado al conectar con Firebase.");
          });
        }
        
        // Ensure backend is aware
        await user.reload();
        final refreshedUser = _auth.currentUser ?? user;
        return await getUserEntityFromBackend(refreshedUser);
      } else {
        throw Exception("Usuario no autenticado");
      }
    } catch (e) {
      throw Exception("Error verificando código SMS: $e");
    }
  }
}
