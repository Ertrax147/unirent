import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleContinue() async {
    if (_selectedRole == null) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    if (_selectedRole == 'estudiante' && !user.email.endsWith('@ufromail.cl')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los estudiantes deben usar un correo @ufromail.cl'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).assignRole(_selectedRole!);
    
    if (_selectedRole == 'arrendador') {
      // Go to MFA / Verification
      if (mounted) context.go('/mfa');
    } else {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Crear cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Row(
              children: [
                _buildStep(1, 'Rol', isActive: true),
                _buildLine(),
                _buildStep(2, 'Verificación', isActive: false),
                _buildLine(),
                _buildStep(3, 'Listo', isActive: false),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Selecciona cómo usarás UniRent. Puedes cambiarlo más adelante desde tu perfil.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            
            _RoleOptionCard(
              title: 'Soy estudiante',
              subtitle: 'Busco arriendo cerca de mi universidad.',
              icon: Icons.school_outlined,
              isSelected: _selectedRole == 'estudiante',
              onTap: () => setState(() => _selectedRole = 'estudiante'),
            ),
            const SizedBox(height: 16),
            
            _RoleOptionCard(
              title: 'Soy arrendador',
              subtitle: 'Publico propiedades para estudiantes.',
              icon: Icons.home_work_outlined,
              isSelected: _selectedRole == 'arrendador',
              onTap: () => setState(() => _selectedRole = 'arrendador'),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedRole != null && authState.status != AuthStatus.authenticating) 
                    ? _handleContinue 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.status == AuthStatus.authenticating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continuar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text.rich(
                  TextSpan(
                    text: '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: 'Inicia sesión',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label, {required bool isActive}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
          child: Text(
            number.toString(),
            style: TextStyle(fontSize: 12, color: isActive ? Colors.white : Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF1E3A5F) : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
        height: 1,
        color: Colors.grey.shade300,
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
