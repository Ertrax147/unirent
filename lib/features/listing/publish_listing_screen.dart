import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublishListingScreen extends ConsumerStatefulWidget {
  const PublishListingScreen({super.key});

  @override
  ConsumerState<PublishListingScreen> createState() => _PublishListingScreenState();
}

class _PublishListingScreenState extends ConsumerState<PublishListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _tipo = 'habitación';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Inmueble')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    Text('Agregar hasta 8 fotos', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Precio mensual (CLP)'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de inmueble'),
                items: const [
                  DropdownMenuItem(value: 'habitación', child: Text('Habitación')),
                  DropdownMenuItem(value: 'departamento', child: Text('Departamento')),
                  DropdownMenuItem(value: 'pensión', child: Text('Pensión')),
                ],
                onChanged: (val) => setState(() => _tipo = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Publicación guardada en Firestore (MOCK)')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
