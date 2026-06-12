import 'package:unirent/core/network/api_client.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/chat/domain/entities/chat_message_entity.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<ChatRoomEntity> getOrCreateChatRoom(int listingId) async {
    try {
      final response = await _apiClient.post('/chats', {'listingId': listingId});
      return ChatRoomEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al iniciar o recuperar el chat: $e');
    }
  }

  Future<List<ChatRoomEntity>> getUserChats() async {
    try {
      final response = await _apiClient.get('/chats');
      if (response is List) {
        return response.map((json) => ChatRoomEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener los chats del usuario: $e');
    }
  }

  Future<List<ChatMessageEntity>> getMessages(int chatRoomId) async {
    try {
      final response = await _apiClient.get('/chats/$chatRoomId/messages');
      if (response is List) {
        return response.map((json) => ChatMessageEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  Future<ChatMessageEntity> sendMessage(int chatRoomId, String content) async {
    try {
      final response = await _apiClient.post('/chats/$chatRoomId/messages', {'content': content});
      return ChatMessageEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al enviar el mensaje: $e');
    }
  }

  Future<ChatRoomEntity> agreeToRent(int chatRoomId) async {
    try {
      final response = await _apiClient.post('/chats/$chatRoomId/agree', {});
      return ChatRoomEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al acordar el arriendo: $e');
    }
  }
}
