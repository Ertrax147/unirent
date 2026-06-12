class ChatRoomEntity {
  final int id;
  final String studentId;
  final String landlordId;
  final int listingId;
  final String? lastMessageTime;

  ChatRoomEntity({
    required this.id,
    required this.studentId,
    required this.landlordId,
    required this.listingId,
    this.lastMessageTime,
  });

  factory ChatRoomEntity.fromJson(Map<String, dynamic> json) {
    return ChatRoomEntity(
      id: json['id'],
      studentId: json['studentId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      listingId: json['listingId'] ?? 0,
      lastMessageTime: json['lastMessageTime'],
    );
  }
}
