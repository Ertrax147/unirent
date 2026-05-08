import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MfaScreen extends StatelessWidget {
  const MfaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu número de teléfono',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Por seguridad, verificamos los perfiles de arrendadores.',
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Número de teléfono',
                prefixText: '+56 9 ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate verification success
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Enviar código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
