import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        if (next.user!.role == 'unassigned') {
          context.go('/role_selection');
        } else {
          context.go('/home');
        }
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Error de autenticación')),
        );
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Top curved background
          ClipPath(
            clipper: _TopCurveClipper(),
            child: Container(
              height: 350,
              width: double.infinity,
              color: const Color(0xFF1E3A5F), // Dark blue
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.school, size: 48, color: Color(0xFF1E3A5F)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'UniRent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Arriendos universitarios seguros',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const SizedBox(height: 24),
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión con tu cuenta de Google universitaria para continuar.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  
                  // Google Sign-In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red), // Simplification for Google icon
                      label: authState.status == AuthStatus.authenticating 
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Continuar con Google',
                              style: TextStyle(color: Colors.black87, fontSize: 16),
                            ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: authState.status == AuthStatus.authenticating
                          ? null
                          : () {
                              ref.read(authStateProvider.notifier).signInWithGoogle();
                            },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Los '),
                                TextSpan(text: 'estudiantes', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' deben usar su correo institucional universitario. Los '),
                                TextSpan(text: 'arrendadores', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: ' pueden ingresar con cualquier cuenta Google.'),
                              ],
                            ),
                            style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text.rich(
                        TextSpan(
                          text: '¿Primera vez en UniRent? ',
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Crear cuenta',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 2, size.height + 40, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
