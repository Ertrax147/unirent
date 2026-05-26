import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockChats = [
      {
        'id': '1',
        'name': 'Juan Pérez',
        'property': 'Habitación Centro',
        'lastMessage': '¡Hola! Sigue disponible la habitación?',
        'time': '10:42 AM',
        'unread': 2,
        'avatar': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'id': '2',
        'name': 'María González',
        'property': 'Depto Pueblo Nuevo',
        'lastMessage': 'Perfecto, nos vemos mañana para mostrarte el depto.',
        'time': 'Ayer',
        'unread': 0,
        'avatar': 'https://i.pravatar.cc/150?img=5',
      },
      {
        'id': '3',
        'name': 'Carlos Rojas',
        'property': 'Pieza UFRO',
        'lastMessage': 'Gracias por la info.',
        'time': 'Lunes',
        'unread': 0,
        'avatar': 'https://i.pravatar.cc/150?img=12',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // In case it's pushed, but here it's in a tab
      ),
      body: ListView.separated(
        itemCount: mockChats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat['avatar']),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chat['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  chat['time'],
                  style: TextStyle(
                    color: chat['unread'] > 0 ? const Color(0xFF1E3A5F) : Colors.grey,
                    fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  chat['property'],
                  style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chat['unread'] > 0 ? Colors.black87 : Colors.grey.shade600,
                          fontWeight: chat['unread'] > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (chat['unread'] > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chat['unread']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () {
              context.push('/chat/${chat['id']}');
            },
          );
        },
      ),
    );
  }
}
