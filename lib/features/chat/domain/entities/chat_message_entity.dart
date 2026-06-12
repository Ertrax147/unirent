class ChatMessageEntity {
  final int id;
  final int chatRoomId;
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
      id: json['id'],
      chatRoomId: json['chatRoomId'] ?? 0,
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
