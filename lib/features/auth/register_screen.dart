import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRole = 'estudiante';
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() {
      setState(() {
        _isEmailValid = _emailCtrl.text.endsWith('@ufromail.cl');
      });
    });
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Mock Firebase email verification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de verificación enviado a Firebase.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Correo institucional (@ufromail.cl)',
                  suffixIcon: _emailCtrl.text.isNotEmpty
                      ? Icon(
                          _isEmailValid ? Icons.check_circle : Icons.cancel,
                          color: _isEmailValid ? Colors.green : Colors.red,
                        )
                      : null,
                ),
                validator: Validators.validateUfroEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                  DropdownMenuItem(value: 'arrendador', child: Text('Arrendador')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
