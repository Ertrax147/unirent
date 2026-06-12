import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key});

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    
    // Asumimos el prefijo +569 por el diseño de UI
    final formattedPhone = '+569$phone';
    
    ref.read(authStateProvider.notifier).sendSmsCode(formattedPhone);
  }

  void _verifyCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    
    ref.read(authStateProvider.notifier).verifySmsCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      } else if (next.status == AuthStatus.authenticated && next.user?.isPhoneVerified == true) {
        context.go('/home');
      }
    });

    final isCodeSent = authState.verificationId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación SMS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
              context.go('/login');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCodeSent ? 'Ingresa el código SMS' : 'Ingresa tu número de teléfono',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isCodeSent 
                ? 'Hemos enviado un código a tu número.' 
                : 'Por seguridad, verificamos los perfiles de arrendadores.',
            ),
            const SizedBox(height: 32),
            
            if (!isCodeSent)
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  prefixText: '+56 9 ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Código SMS',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ref.read(authStateProvider.notifier).clearVerificationId();
                      },
                      child: const Text('¿Te equivocaste de número? Cambiar'),
                    ),
                  ),
                ],
              ),
              
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: authState.status == AuthStatus.authenticating 
                  ? null 
                  : (isCodeSent ? _verifyCode : _sendCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.status == AuthStatus.authenticating
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
                        isCodeSent ? 'Verificar código' : 'Enviar código',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
