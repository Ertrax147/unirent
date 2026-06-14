import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String role;
  
  const PhoneVerificationScreen({super.key, required this.role});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendSms() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un número válido')),
      );
      return;
    }
    
    // We expect the authProvider to have a sendSmsCode method
    await ref.read(authStateProvider.notifier).sendSmsCode(_phoneController.text);
    
    final state = ref.read(authStateProvider);
    if (state.status == AuthStatus.error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error')));
    } else {
      setState(() {
        _codeSent = true;
      });
    }
  }

  void _verifyCode() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código')),
      );
      return;
    }
    
    await ref.read(authStateProvider.notifier).verifySmsCode(_codeController.text);
    
    final state = ref.read(authStateProvider);
    if (state.status == AuthStatus.error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error')));
      return;
    }
    
    // Once SMS is verified with Firebase, we register the user in Spring Boot
    await ref.read(authStateProvider.notifier).registrarUsuario(widget.role, _phoneController.text);
    
    final finalState = ref.read(authStateProvider);
    if (finalState.status == AuthStatus.error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(finalState.errorMessage ?? 'Error')));
    } else {
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación SMS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _codeSent ? 'Ingresa el código que te enviamos' : 'Verifica tu número para publicar propiedades',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  hintText: '+56 9 1234 5678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendSms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar SMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Código de 6 dígitos',
                  prefixIcon: const Icon(Icons.message),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verificar y Continuar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
