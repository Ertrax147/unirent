import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state to redirect
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        context.go('/login');
      } else if (next.status == AuthStatus.authenticated && next.user != null) {
        if (next.user!.role == 'unassigned') {
          context.go('/role_selection');
        } else if (next.user!.role == 'admin') {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.school, size: 100, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'UniRent',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
