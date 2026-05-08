import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isArrendador = authState.user?.role == 'arrendador';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UniRent',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
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
      ),
      body: Column(
        children: [
          // Search and Filters
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
          
          // Horizontal Filters (Reactive later)
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
          
          // Listings
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _ListingCardMock(index: index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isArrendador
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                context.push('/publish');
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        onDestinationSelected: (idx) {},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1E3A5F)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
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

class _ListingCardMock extends StatelessWidget {
  final int index;
  
  const _ListingCardMock({required this.index});

  @override
  Widget build(BuildContext context) {
    final listings = [
      {
        'title': 'Habitación individual cerca UFRO',
        'price': '\$280.000/mes',
        'location': 'Centro, Temuco',
        'type': 'Individual',
        'rating': '4.8',
      },
      {
        'title': 'Departamento amoblado 2 personas',
        'price': '\$420.000/mes',
        'location': 'Pueblo Nuevo, Temuco',
        'type': 'Compartida',
        'rating': '4.5',
      },
      {
        'title': 'Pieza con baño privado',
        'price': '\$320.000/mes',
        'location': 'Santa Rosa, Temuco',
        'type': 'Individual',
        'rating': '4.9',
      },
      {
        'title': 'Departamento estudio UFRO',
        'price': '\$350.000/mes',
        'location': 'Av. Alemania, Temuco',
        'type': 'Estudio',
        'rating': '4.7',
      },
    ];
    
    final item = listings[index % listings.length];

    return GestureDetector(
      onTap: () {
        context.push('/listing/$index');
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
            // Image Placeholder
            Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['price']!,
                      style: const TextStyle(
                        color: Color(0xFF1E3A5F),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['location']!,
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
                            item['type']!,
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
                              item['rating']!,
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
