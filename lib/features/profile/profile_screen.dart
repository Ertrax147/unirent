import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userEmail = authState.userMetadata?['email'] ?? 'Usuario';
    final userRole = authState.userMetadata?['role'] ?? 'Estudiante';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF01696F),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Rol: $userRole',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text(' 4.8 (12 valoraciones)', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
