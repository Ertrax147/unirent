class ChatRoomEntity {
  final int id;
  final String studentId;
  final String landlordId;
  final int listingId;
  final String? lastMessageTime;
  final bool studentAgreed;
  final bool landlordAgreed;
  final bool isClosed;

  ChatRoomEntity({
    required this.id,
    required this.studentId,
    required this.landlordId,
    required this.listingId,
    this.lastMessageTime,
    this.studentAgreed = false,
    this.landlordAgreed = false,
    this.isClosed = false,
  });

  factory ChatRoomEntity.fromJson(Map<String, dynamic> json) {
    return ChatRoomEntity(
      id: json['id'],
      studentId: json['studentId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      listingId: json['listingId'] ?? 0,
      lastMessageTime: json['lastMessageTime'],
      studentAgreed: json['studentAgreed'] ?? false,
      landlordAgreed: json['landlordAgreed'] ?? false,
      isClosed: json['closed'] ?? false, // Spring Boot isClosed -> isClosed field in json, sometimes jackson makes it 'closed'. Let's parse both 'closed' and 'isClosed'
    );
  }
}
