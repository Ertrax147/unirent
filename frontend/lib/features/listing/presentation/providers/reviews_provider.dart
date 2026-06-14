import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/core/network/api_client.dart';

class ReviewEntity {
  final String id;
  final String authorUserId;
  final String targetUserId;
  final String chatRoomId;
  final int stars;
  final String comment;
  final DateTime? timestamp;
  final bool isStudent;

  ReviewEntity({
    required this.id,
    required this.authorUserId,
    required this.targetUserId,
    required this.chatRoomId,
    required this.stars,
    required this.comment,
    required this.timestamp,
    required this.isStudent,
  });

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['id']?.toString() ?? '',
      authorUserId: json['authorUserId'] ?? '',
      targetUserId: json['targetUserId'] ?? '',
      chatRoomId: json['chatRoomId'] ?? '',
      stars: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      timestamp: _parseTimestamp(json['timestamp']),
      isStudent: json['isStudent'] ?? false,
    );
  }

  static DateTime? _parseTimestamp(dynamic ts) {
    if (ts == null) return null;
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    if (ts is String) return DateTime.tryParse(ts);
    return null;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Provider que devuelve todas las reviews para un usuario específico (ahora desde Spring Boot)
final userReviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, userId) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/reviews/$userId');
    if (response is List) {
      return response.map((json) => ReviewEntity.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    print('Error fetching reviews from backend: $e');
    return [];
  }
});

class ReviewStats {
  final double average;
  final int count;
  ReviewStats(this.average, this.count);
}

// Provider que calcula las estadísticas basándose en la misma petición
final userReviewStatsProvider = FutureProvider.family<ReviewStats, String>((ref, userId) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.get('/reviews/$userId/stats');
    if (response is Map<String, dynamic>) {
      double average = (response['average'] ?? 0).toDouble();
      int count = response['totalReviews'] ?? 0;
      return ReviewStats(average, count);
    }
  } catch (e) {
    print('Error fetching review stats from backend: $e');
  }
  return ReviewStats(0.0, 0);
});
