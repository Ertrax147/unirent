import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import 'package:unirent/core/network/api_client.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '825536205407-bhdv8668e7g2b95vc9361sdjbf684im3.apps.googleusercontent.com',
    // We pass the Web Client ID explicitly as serverClientId.
    // This is required on Android/Web to get the idToken for Firebase.
    serverClientId: '825536205407-bhdv8668e7g2b95vc9361sdjbf684im3.apps.googleusercontent.com',
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
    // Forzar la actualización del token para obtener los últimos claims desde el backend
    final idTokenResult = await user.getIdTokenResult(true);
    final role = idTokenResult.claims?['rol'] as String?;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Usuario',
      photoUrl: user.photoURL ?? '',
      role: role ?? 'unassigned',
      isPhoneVerified: false, // Por ahora no usamos auth telefónica directa
    );
  }

  Future<UserEntity> registrarUsuario(String role, String telefono) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado en Firebase");

    String endpoint = role.toLowerCase() == 'arrendador' 
        ? '/auth/arrendador/registro' 
        : '/auth/estudiante/registro';

    final response = await _apiClient.post(endpoint, {
      'rol': role.toUpperCase(), // backend espera ESTUDIANTE o ARRENDADOR
      'telefono': telefono,
    });
    
    // El backend acaba de asignar un "custom claim". Necesitamos refrescar el token para verlo.
    final refreshedUser = _auth.currentUser;
    if (refreshedUser != null) {
      return await getUserEntityFromBackend(refreshedUser);
    }
    
    return UserEntity(
      id: response['id'],
      email: response['correo'] ?? '', 
      name: response['nombre'] ?? 'Usuario',
      photoUrl: '',
      role: response['rol'].toString().toLowerCase(),
      isPhoneVerified: false,
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
