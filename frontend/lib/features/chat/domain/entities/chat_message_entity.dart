class ChatMessageEntity {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final String timestamp;

  ChatMessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'].toString(),
      chatRoomId: json['chatRoomId'].toString(),
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? json['sentAt'] ?? '',
    );
  }
}
