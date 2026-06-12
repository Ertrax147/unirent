import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/listing_provider.dart';

class PublishListingScreen extends ConsumerStatefulWidget {
  const PublishListingScreen({super.key});

  @override
  ConsumerState<PublishListingScreen> createState() => _PublishListingScreenState();
}

class _PublishListingScreenState extends ConsumerState<PublishListingScreen> {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Individual';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _publishListing() async {
    if (_titleController.text.isEmpty || _addressController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa los campos requeridos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(listingRepositoryProvider);
      await repository.createListing({
        'title': _titleController.text,
        'price': '\$${_priceController.text}/mes',
        'location': _addressController.text,
        'type': _selectedType,
        'rating': '5.0', // Default para nuevos
        'imageUrl': 'assets/images/prop_0.png', // Imagen MVP temporal
      });

      if (mounted) {
        // Refresh listings
        ref.invalidate(listingsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Propiedad publicada con éxito!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
            Text('Para esta versión demo, se usará una imagen predeterminada automáticamente.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 24),
            
            _buildTextField('Título del aviso', 'Ej: Habitación individual cerca UFRO', _titleController),
            const SizedBox(height: 16),
            _buildTextField('Dirección', 'Ingresa la dirección completa', _addressController),
            const SizedBox(height: 16),
            
            const Text('Precio mensual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
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
              value: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                DropdownMenuItem(value: 'Compartida', child: Text('Compartida')),
                DropdownMenuItem(value: 'Estudio', child: Text('Estudio')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe las características del lugar, servicios incluidos, reglas, etc.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: _isLoading ? null : _publishListing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Publicar aviso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
