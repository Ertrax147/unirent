import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import 'package:unirent/features/chat/data/repositories/chat_repository.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/chat/domain/entities/chat_message_entity.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// Provider para la lista de todos los chats de un usuario
final userChatsProvider = AsyncNotifierProvider<UserChatsNotifier, List<ChatRoomEntity>>(() {
  return UserChatsNotifier();
});

class UserChatsNotifier extends AsyncNotifier<List<ChatRoomEntity>> {
  @override
  Future<List<ChatRoomEntity>> build() async {
    final authState = ref.watch(authStateProvider);
    if (authState.user == null) return [];
    
    final repository = ref.watch(chatRepositoryProvider);
    return await repository.getUserChats();
  }

  Future<ChatRoomEntity> createOrGetChat(int listingId) async {
    final repository = ref.read(chatRepositoryProvider);
    final chatRoom = await repository.getOrCreateChatRoom(listingId);
    
    // Refresh chats after creating one
    ref.invalidateSelf();
    return chatRoom;
  }
}

// AutoDispose Provider para los mensajes de un chat específico con Polling
final chatMessagesProvider = AsyncNotifierProvider.family.autoDispose<ChatMessagesNotifier, List<ChatMessageEntity>, int>(() {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends AutoDisposeFamilyAsyncNotifier<List<ChatMessageEntity>, int> {
  Timer? _timer;

  @override
  Future<List<ChatMessageEntity>> build(int arg) async {
    // Stop any previous timer
    _timer?.cancel();

    // Start polling every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollMessages();
    });

    // Cleanup when provider is disposed (user leaves screen)
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Initial fetch
    final repository = ref.read(chatRepositoryProvider);
    return await repository.getMessages(arg);
  }

  Future<void> _pollMessages() async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      final newMessages = await repository.getMessages(arg);
      
      // Update state if we have new messages (simple comparison by length for MVP)
      if (state.value == null || newMessages.length != state.value!.length) {
        state = AsyncData(newMessages);
      }
    } catch (e) {
      // Ignore poll errors to not disrupt UX
    }
  }

  Future<void> sendMessage(String content) async {
    final repository = ref.read(chatRepositoryProvider);
    
    // Optimistic UI update could go here, but let's keep it simple for now
    
    await repository.sendMessage(arg, content);
    // Refresh immediately after sending
    await _pollMessages();
  }
}
