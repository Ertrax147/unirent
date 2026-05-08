import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublishListingScreen extends StatelessWidget {
  const PublishListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Publicar aviso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fotos del lugar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Hasta 8 fotos', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: Colors.grey.shade400),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            _buildTextField('Título del aviso', 'Ej: Habitación individual cerca UFRO'),
            const SizedBox(height: 16),
            _buildTextField('Dirección', 'Ingresa la dirección completa'),
            const SizedBox(height: 16),
            
            const Text('Precio mensual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '280000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            const Text('Tipo de habitación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              hint: const Text('Selecciona una opción'),
              items: const [
                DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                DropdownMenuItem(value: 'Compartida', child: Text('Compartida')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            
            _buildTextField('Fecha de disponibilidad', 'dd-mm-aaaa', suffixIcon: Icons.calendar_today),
            const SizedBox(height: 16),
            
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe las características del lugar, servicios incluidos, reglas, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Ubicación en el mapa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text('Confirmar ubicación en mapa', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Simulate publish
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Publicar aviso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
