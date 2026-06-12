import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import 'package:unirent/features/chat/presentation/providers/chat_provider.dart';
import 'package:unirent/features/auth/presentation/providers/user_public_provider.dart';
import 'package:unirent/features/listing/presentation/providers/listing_provider.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/chat/presentation/screens/review_screen.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    final chatIdInt = int.tryParse(widget.chatId);
    if (chatIdInt != null) {
      ref.read(chatMessagesProvider(chatIdInt).notifier).sendMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatIdInt = int.tryParse(widget.chatId) ?? 0;
    final messagesState = ref.watch(chatMessagesProvider(chatIdInt));
    final authState = ref.watch(authStateProvider);
    final myUserId = authState.user?.id ?? '';
    
    final chatsState = ref.watch(userChatsProvider);
    String otherUserId = '';
    String propertyTitle = 'Propiedad';
    ChatRoomEntity? currentChat;
    if (chatsState.value != null) {
      try {
        currentChat = chatsState.value!.firstWhere((c) => c.id == chatIdInt);
        otherUserId = currentChat.studentId == myUserId ? currentChat.landlordId : currentChat.studentId;
        
        final listingsState = ref.watch(listingsProvider);
        if (listingsState.value != null) {
          try {
            final listing = listingsState.value!.firstWhere((l) => l.id == currentChat!.listingId);
            propertyTitle = listing.title;
          } catch (_) {}
        }
      } catch (_) {}
    }
    
    final publicUserState = ref.watch(userPublicProvider(otherUserId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            publicUserState.when(
              data: (user) => CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                backgroundImage: user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: user['photoUrl'] == null || user['photoUrl'].toString().isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              loading: () => const CircleAvatar(radius: 16, child: CircularProgressIndicator()),
              error: (_, __) => const CircleAvatar(radius: 16, child: Icon(Icons.error)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  publicUserState.when(
                    data: (user) => Text(user['displayName'] ?? 'Usuario', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    loading: () => const Text('Cargando...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    error: (_, __) => const Text('Usuario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Text(propertyTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          if (currentChat != null)
            IconButton(
              icon: const Icon(Icons.handshake),
              onPressed: () => _showAgreementDialog(context, currentChat!, myUserId),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No hay mensajes aún. ¡Escribe el primero!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == myUserId;
                    
                    String timeStr = "";
                    try {
                      final dt = DateTime.parse(msg.timestamp).toLocal();
                      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    } catch (e) {
                      timeStr = msg.timestamp;
                    }

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgreementDialog(BuildContext context, ChatRoomEntity chat, String myUserId) {
    final isStudent = chat.studentId == myUserId;
    final iAgreed = isStudent ? chat.studentAgreed : chat.landlordAgreed;
    final otherAgreed = isStudent ? chat.landlordAgreed : chat.studentAgreed;
    final isClosed = chat.isClosed;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.handshake, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Acuerdo de Arriendo',
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isClosed) ...[
                const Text('¡Felicidades! 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                const Text('El arriendo se ha concretado exitosamente. La propiedad ya no está visible para otros estudiantes.'),
              ] else if (iAgreed && !otherAgreed) ...[
                const Text('Has confirmado tu intención de arrendar.', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Estamos esperando a que la otra persona también confirme. Una vez que ambos acepten, el arriendo se concretará.'),
              ] else if (!iAgreed && otherAgreed) ...[
                const Text('La otra persona ya confirmó su intención de arrendar.', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(isStudent 
                  ? '¿Confirmas que deseas arrendar esta propiedad?' 
                  : '¿Confirmas que le arrendarás a este estudiante?'),
              ] else ...[
                Text(isStudent 
                  ? '¿Confirmas tu intención de arrendar esta propiedad?' 
                  : '¿Confirmas tu intención de arrendarle a este estudiante?'),
                const SizedBox(height: 8),
                const Text('Al confirmar ambas partes, la propiedad dejará de estar disponible para el resto.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
          actions: [
            if (isClosed) ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                        chatRoomId: chat.id,
                        otherUserName: isStudent
                          ? (ref.read(userPublicProvider(chat.landlordId)).valueOrNull?['displayName'] ?? 'Arrendador')
                          : (ref.read(userPublicProvider(chat.studentId)).valueOrNull?['displayName'] ?? 'Estudiante'),
                        otherUserId: isStudent ? chat.landlordId : chat.studentId,
                        isStudent: isStudent,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text('Calificar ahora'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(iAgreed ? 'Cerrar' : 'Cancelar'),
              ),
              if (!iAgreed)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await ref.read(userChatsProvider.notifier).agreeToRent(chat.id);
                      // Invalidar el provider de listings para que desaparezca la propiedad si el acuerdo se completó
                      ref.invalidate(listingsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Acuerdo confirmado!')));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F), foregroundColor: Colors.white),
                  child: const Text('Confirmar Arriendo'),
                ),
            ],
          ],
        );
      },
    );
  }
}
