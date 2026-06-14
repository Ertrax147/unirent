import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';
import 'package:unirent/features/chat/data/repositories/chat_repository.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/chat/domain/entities/chat_message_entity.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// Stream de todos los chats
final userChatsStreamProvider = StreamProvider<List<ChatRoomEntity>>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.user == null) return const Stream.empty();
  
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUserChatsStream();
});

// Stream de los mensajes de un chat específico
final chatMessagesStreamProvider = StreamProvider.family<List<ChatMessageEntity>, String>((ref, chatRoomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessagesStream(chatRoomId);
});

// Provider legacy for backward compatibility of methods like createOrGetChat, agreeToRent
final userChatsProvider = AsyncNotifierProvider<UserChatsNotifier, List<ChatRoomEntity>>(() {
  return UserChatsNotifier();
});

class UserChatsNotifier extends AsyncNotifier<List<ChatRoomEntity>> {
  @override
  Future<List<ChatRoomEntity>> build() async {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getUserChats();
  }

  Future<ChatRoomEntity> createOrGetChat(String listingId, String landlordId) async {
    final repository = ref.read(chatRepositoryProvider);
    final chatRoom = await repository.getOrCreateChatRoom(listingId, landlordId);
    return chatRoom;
  }

  Future<ChatRoomEntity> agreeToRent(String chatRoomId) async {
    final repository = ref.read(chatRepositoryProvider);
    final chatRoom = await repository.agreeToRent(chatRoomId);
    return chatRoom;
  }
}

final chatMessagesActionProvider = Provider<ChatMessagesAction>((ref) {
  return ChatMessagesAction(ref);
});

class ChatMessagesAction {
  final Ref ref;
  ChatMessagesAction(this.ref);

  Future<void> sendMessage(String chatRoomId, String content) async {
    final repository = ref.read(chatRepositoryProvider);
    await repository.sendMessage(chatRoomId, content);
  }
}
