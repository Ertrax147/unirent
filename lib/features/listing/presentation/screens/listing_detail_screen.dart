import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';

class ListingDetailScreen extends ConsumerWidget {
  final int index;
  
  const ListingDetailScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isEstudiante = authState.user?.role == 'estudiante';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalle de Aviso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel (Placeholder)
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.shade400,
                  child: const Center(child: Icon(Icons.photo, size: 64, color: Colors.white)),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildIconButton(Icons.favorite_border),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.share),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('1/5', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\$280.000/mes',
                    style: TextStyle(
                      color: Color(0xFF1E3A5F),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Av. Francisco Salazar 01145, Centro, Temuco',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Habitación Individual',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _FeatureChip('WiFi incluido'),
                      _FeatureChip('Calefacción'),
                      _FeatureChip('Amoblado'),
                      _FeatureChip('Agua caliente'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Habitación luminosa y amoblada a 5 minutos caminando de la Universidad de La Frontera. Incluye cama, escritorio, clóset y calefacción. Baño compartido con un estudiante más. Internet de alta velocidad incluido en el precio.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(Icons.location_on, size: 40, color: Colors.grey.shade400),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Arrendador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('María González', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9 (23 reseñas)',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Ver perfil'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isEstudiante ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Contactar arrendador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solo estudiantes autenticados pueden contactar',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }
}
