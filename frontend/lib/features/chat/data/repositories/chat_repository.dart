import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unirent/features/chat/domain/entities/chat_room_entity.dart';
import 'package:unirent/features/chat/domain/entities/chat_message_entity.dart';
import 'package:unirent/core/network/api_client.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient(); // for backwards compatibility if needed

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<ChatRoomEntity> getOrCreateChatRoom(String listingId, String landlordId) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    // First try to find an existing chat
    final querySnapshot = await _firestore
        .collection('chats')
        .where('listingId', isEqualTo: listingId)
        .where('studentId', isEqualTo: uid)
        .where('landlordId', isEqualTo: landlordId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      data['id'] = querySnapshot.docs.first.id;
      return ChatRoomEntity.fromJson(data);
    }

    // Create a new chat if it doesn't exist
    final chatDoc = _firestore.collection('chats').doc();
    final newChat = {
      'studentId': uid,
      'landlordId': landlordId,
      'listingId': listingId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'studentAgreed': false,
      'landlordAgreed': false,
      'closed': false,
      'participants': [uid, landlordId] // To make querying easier
    };

    await chatDoc.set(newChat);
    
    // We fetch it back or just manually map it to avoid waiting for serverTimestamp
    return ChatRoomEntity(
      id: chatDoc.id,
      studentId: uid,
      landlordId: landlordId,
      listingId: listingId,
    );
  }

  // Use this for a one-time fetch, but streams are preferred for real-time
  Future<List<ChatRoomEntity>> getUserChats() async {
    final uid = _currentUserId;
    if (uid == null) return [];

    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      // Convierte los Timestamp a String ISO para el Entity
      if (data['lastMessageTime'] is Timestamp) {
        data['lastMessageTime'] = (data['lastMessageTime'] as Timestamp).toDate().toIso8601String();
      }
      return ChatRoomEntity.fromJson(data);
    }).toList();
  }

  Stream<List<ChatRoomEntity>> getUserChatsStream() {
    final uid = _currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['lastMessageTime'] is Timestamp) {
          data['lastMessageTime'] = (data['lastMessageTime'] as Timestamp).toDate().toIso8601String();
        }
        return ChatRoomEntity.fromJson(data);
      }).toList();
    });
  }

  Stream<List<ChatMessageEntity>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['chatRoomId'] = chatRoomId;
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        return ChatMessageEntity.fromJson(data);
      }).toList();
    });
  }

  Future<void> sendMessage(String chatRoomId, String content) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final messageDoc = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final batch = _firestore.batch();
    
    // Create message
    batch.set(messageDoc, {
      'senderId': uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update lastMessageTime on the chat room
    final chatDoc = _firestore.collection('chats').doc(chatRoomId);
    batch.update(chatDoc, {
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<ChatRoomEntity> agreeToRent(String chatRoomId) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not authenticated');

    final chatDoc = _firestore.collection('chats').doc(chatRoomId);
    final snapshot = await chatDoc.get();
    
    if (!snapshot.exists) throw Exception('Chat not found');
    final data = snapshot.data()!;
    
    bool isStudent = data['studentId'] == uid;
    
    if (isStudent) {
      data['studentAgreed'] = true;
    } else {
      data['landlordAgreed'] = true;
    }
    
    bool bothAgreed = data['studentAgreed'] == true && data['landlordAgreed'] == true;

    if (bothAgreed) {
      await chatDoc.update({
        'studentAgreed': data['studentAgreed'],
        'landlordAgreed': data['landlordAgreed'],
        'closed': true,
      });
      data['closed'] = true;
      
      // Cerrar aviso en backend
      try {
        await _apiClient.put('/avisos/${data['listingId']}/cerrar', {});
      } catch (e) {
        print('Error al cerrar el aviso en el backend: $e');
      }
    } else {
      await chatDoc.update({
        'studentAgreed': data['studentAgreed'],
        'landlordAgreed': data['landlordAgreed'],
      });
    }

    data['id'] = chatDoc.id;
    if (data['lastMessageTime'] is Timestamp) {
      data['lastMessageTime'] = (data['lastMessageTime'] as Timestamp).toDate().toIso8601String();
    }
    return ChatRoomEntity.fromJson(data);
  }
}
