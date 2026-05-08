import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isArrendador = authState.userMetadata?['role'] == 'arrendador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              leading: const Icon(Icons.search),
              hintText: 'Buscar por sector o comuna...',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return ListingCardMock(index: index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isArrendador
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/publish');
              },
              icon: const Icon(Icons.add),
              label: const Text('Publicar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          if (idx == 3) context.push('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Mensajes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Precio máximo'),
          Slider(value: 200000, min: 50000, max: 500000, onChanged: (v) {}),
          const SizedBox(height: 16),
          const Text('Tipo'),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('Habitación'), selected: true, onSelected: (v) {}),
              FilterChip(label: const Text('Depto'), selected: false, onSelected: (v) {}),
              FilterChip(label: const Text('Pensión'), selected: false, onSelected: (v) {}),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          )
        ],
      ),
    );
  }
}

class ListingCardMock extends StatelessWidget {
  final int index;
  const ListingCardMock({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/listing/$index');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              color: Colors.grey.shade300,
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${150000 + (index * 20000)} CLP',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF01696F)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Habitación • Barrio Universitario'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
