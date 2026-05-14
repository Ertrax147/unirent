import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role Selection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/properties'),
              child: const Text('I am a Student (Go to Properties)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/properties/publish'),
              child: const Text('I am a Landlord (Publish Property)'),
            ),
          ],
        ),
      ),
    );
  }
}
