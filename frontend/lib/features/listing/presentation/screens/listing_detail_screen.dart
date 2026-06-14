import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import 'package:unirent/features/home/presentation/widgets/hover_heart_button.dart';
import 'package:unirent/features/auth/presentation/providers/user_public_provider.dart';
import 'package:unirent/features/listing/presentation/providers/aviso_arriendo_provider.dart';
import 'package:unirent/features/chat/presentation/providers/chat_provider.dart';
import 'package:unirent/features/listing/presentation/providers/reviews_provider.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final dynamic index;
  
  const ListingDetailScreen({super.key, required this.index});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  bool _isStartingChat = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isEstudiante = authState.user?.role.toUpperCase() == 'ESTUDIANTE';
    
    final listingsState = ref.watch(avisosProvider);
    final listings = listingsState.value ?? [];
    
    // Encontrar el aviso específico por ID
    final listing = listings.firstWhere(
      (l) => l.id == widget.index,
      orElse: () => throw Exception('Listing not found'),
    );

    final userPublicState = ref.watch(userPublicProvider(listing.arrendadorId));

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
            // Carrusel de Imágenes
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.asset('assets/images/prop_0.png', fit: BoxFit.cover),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: HoverHeartButton(index: widget.index.hashCode, iconSize: 20, padding: 8.0),
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.share),
                    ],
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${listing.precio.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF1E3A5F),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.titulo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.ciudad,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Etiqueta (Badge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Arriendo',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Características
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
                    listing.descripcion,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Ubicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (listing.ubicacion['lat'] != null && listing.ubicacion['lng'] != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(listing.ubicacion['lat']!, listing.ubicacion['lng']!),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.unirent.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(listing.ubicacion['lat']!, listing.ubicacion['lng']!),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
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
                  userPublicState.when(
                    data: (userInfo) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: userInfo['photoUrl'] != null && userInfo['photoUrl'].toString().isNotEmpty
                                ? NetworkImage(userInfo['photoUrl'])
                                : null,
                            child: userInfo['photoUrl'] == null || userInfo['photoUrl'].toString().isEmpty
                                ? const Icon(Icons.person, color: Colors.blue)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userInfo['displayName'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final statsAsync = ref.watch(userReviewStatsProvider(listing.arrendadorId));
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        context.push('/listing/${widget.index}/reviews', extra: listing.arrendadorId);
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.orange, size: 16),
                                          const SizedBox(width: 4),
                                          statsAsync.when(
                                            data: (stats) => Text(
                                              stats.count == 0 
                                                ? 'Sin reseñas'
                                                : '${stats.average.toStringAsFixed(1)} (${stats.count} reseñas)',
                                              style: TextStyle(
                                                color: Colors.blue.shade600,
                                                fontSize: 14,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            loading: () => const Text('Cargando...', style: TextStyle(fontSize: 12)),
                                            error: (_, __) => const Text('Error', style: TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Calificar'),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const Text('Error al cargar datos del arrendador'),
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
                onPressed: isEstudiante && !_isStartingChat ? () async {
                  setState(() {
                    _isStartingChat = true;
                  });
                  try {
                    final chatRoom = await ref.read(userChatsProvider.notifier).createOrGetChat(widget.index.toString(), listing.arrendadorId);
                    if (mounted) {
                      context.push('/chat/${chatRoom.id}');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al iniciar chat: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isStartingChat = false;
                      });
                    }
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isStartingChat 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Contactar arrendador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
