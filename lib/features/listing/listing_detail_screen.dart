import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListingDetailScreen extends ConsumerWidget {
  final int index;

  const ListingDetailScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Inmueble')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 250,
              child: PageView(
                children: [
                   Container(color: Colors.grey.shade300, child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey))),
                   Container(color: Colors.grey.shade400, child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${150000 + (index * 20000)} CLP / mes',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF01696F)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Habitación amoblada • Barrio Universitario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  const Text('Descripción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Excelente habitación a 5 minutos de la UFRO. Incluye internet, agua y luz. Ambiente tranquilo ideal para estudiar.'),
                  const SizedBox(height: 16),
                  // Mock Google Maps
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('Mapa (Google Maps Static Widget)')),
                  ),
                  const SizedBox(height: 16),
                  // Landlord Card
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: const Text('Juan Pérez (Arrendador)'),
                      subtitle: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' 4.5'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement contact
                        },
                        child: const Text('Contactar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
