import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/chat/presentation/providers/chat_provider.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import 'package:unirent/features/auth/presentation/providers/user_public_provider.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/listing/presentation/providers/aviso_arriendo_provider.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsState = ref.watch(userChatsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: chatsState.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('Aún no tienes mensajes.'));
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ChatListTile(chat: chats[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ChatListTile extends ConsumerWidget {
  final ChatRoomEntity chat;

  const _ChatListTile({required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final myUserId = authState.user?.id ?? '';
    
    // Si soy el estudiante, hablo con el landlord. Si soy el landlord, hablo con el estudiante.
    final otherUserId = chat.studentId == myUserId ? chat.landlordId : chat.studentId;
    
    final publicUserState = ref.watch(userPublicProvider(otherUserId));
    
    final listingAsync = ref.watch(avisoDetailProvider(chat.listingId));

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: publicUserState.when(
        data: (user) => CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
              ? NetworkImage(user['photoUrl'])
              : null,
          child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
              ? const Icon(Icons.person, color: Colors.blue)
              : null,
        ),
        loading: () => const CircleAvatar(radius: 28, child: CircularProgressIndicator()),
        error: (_, __) => const CircleAvatar(radius: 28, child: Icon(Icons.error)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: publicUserState.when(
              data: (user) => Text(
                user['displayName'] ?? 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              loading: () => const Text('Cargando...', style: TextStyle(fontSize: 16)),
              error: (_, __) => const Text('Usuario', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Reciente',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          listingAsync.when(
            data: (listing) => Text(
              listing.titulo,
              style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            loading: () => Text(
              'Cargando propiedad...',
              style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            error: (_, __) => Text(
              'Propiedad #${chat.listingId}',
              style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca para ver mensajes...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      onTap: () {
        context.push('/chat/${chat.id}');
      },
    );
  }
}
