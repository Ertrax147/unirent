import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/hover_heart_button.dart';
import '../../../listing/domain/entities/aviso_arriendo_entity.dart';
import '../../../listing/presentation/providers/aviso_arriendo_provider.dart';

import 'package:unirent/features/chat/presentation/screens/chats_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isArrendador = authState.user?.role.toUpperCase() == 'ARRENDADOR';

    final Widget homeBody = Column(
      children: [
        // Búsqueda y Filtros
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar arriendo...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        
        // Filtros Horizontales
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: const [
              _FilterChip(label: 'Precio máx.'),
              _FilterChip(label: 'Comuna'),
              _FilterChip(label: 'Tipo'),
              _FilterChip(label: 'Disponibilidad'),
            ],
          ),
        ),
        
        // Lista de propiedades desde Spring Boot
        Expanded(
          child: ref.watch(avisosProvider).when(
            data: (listings) {
              if (listings.isEmpty) {
                return const Center(child: Text('No hay propiedades disponibles.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  return _ListingCard(listing: listings[index], index: index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );

    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return homeBody;
        case 1:
          final favoriteState = ref.watch(favoritesProvider);
          if (favoriteState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final favoriteIds = favoriteState.value ?? [];
          if (favoriteIds.isEmpty) {
            return const Center(child: Text('Aún no tienes favoritos.'));
          }

          final listingsState = ref.watch(avisosProvider);
          if (listingsState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final allListings = listingsState.value ?? [];
          final favoriteListings = allListings.where((l) => favoriteIds.contains(l.id.hashCode)).toList();

          if (favoriteListings.isEmpty) {
            return const Center(child: Text('Tus favoritos no están disponibles.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: favoriteListings.length,
            itemBuilder: (context, index) {
              return _ListingCard(listing: favoriteListings[index], index: favoriteListings[index].id);
            },
          );
        case 2:
          return const ChatsListScreen();
        case 3:
          return const Center(child: Text('Perfil'));
        default:
          return homeBody;
      }
    }

    return Scaffold(
      appBar: _selectedIndex == 0 || _selectedIndex == 1 ? AppBar(
        title: Text(
          _selectedIndex == 0 ? 'UniRent' : 'Mis Favoritos',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF1E3A5F)),
            onPressed: () {
              context.push('/profile');
            },
          ),
          const SizedBox(width: 8),
        ],
      ) : null,
      body: getBody(),
      floatingActionButton: isArrendador && _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                context.push('/publish');
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        onDestinationSelected: (idx) {
          if (idx == 3) {
            // El Perfil todavía se abre en pantalla completa
            context.push('/profile');
          } else {
            setState(() {
              _selectedIndex = idx;
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1E3A5F)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: Color(0xFF1E3A5F)),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF1E3A5F)),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1E3A5F)),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _ListingCard extends ConsumerWidget {
  final AvisoArriendoEntity listing;
  final dynamic index;
  
  const _ListingCard({required this.listing, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.push('/listing/${listing.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen de la propiedad
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/prop_0.png', // Imagen de respaldo porque la BD aún no tiene
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: HoverHeartButton(index: listing.id.hashCode, iconSize: 16),
                  ),
                ),
              ],
            ),
            
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${listing.precio.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.ciudad,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Arriendo',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '4.5',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
