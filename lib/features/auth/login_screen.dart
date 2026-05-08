import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockoutTimer = 0;

  void _handleLogin() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta bloqueada. Intenta en $_lockoutTimer segundos.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Mock login check
      if (_emailCtrl.text == 'estudiante@ufromail.cl' || _emailCtrl.text == 'arrendador@ufromail.cl' || _emailCtrl.text == 'admin@ufromail.cl') {
        await ref.read(authStateProvider.notifier).login(_emailCtrl.text, _passCtrl.text);
        if (mounted) context.go('/home'); // AuthRouter logic should ideally handle this, but adding it here for explicitly mock
      } else {
        setState(() {
          _failedAttempts++;
          if (_failedAttempts >= 5) {
            _isLocked = true;
            _lockoutTimer = 30; // 30 sec lockout
            _startLockoutTimer();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Credenciales incorrectas. Intentos: $_failedAttempts/5')),
        );
      }
    }
  }

  void _startLockoutTimer() async {
    while (_lockoutTimer > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _lockoutTimer--;
      });
    }
    setState(() {
      _isLocked = false;
      _failedAttempts = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.maps_home_work_rounded, size: 80, color: Color(0xFF01696F)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo institucional'),
                validator: Validators.validateUfroEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLocked ? null : _handleLogin,
                child: Text(_isLocked ? 'Bloqueado ($_lockoutTimer s)' : 'Iniciar sesión'),
              ),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
