import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/core/network/api_client.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPublicUser(String uid) async {
    try {
      print('=== FETCHING URL: /users/$uid/public ===');
      final response = await _apiClient.get('/users/$uid/public');
      print('=== RESPONSE OK: $response ===');
      
      return {
        'id': response['id'],
        'displayName': response['display_name'] ?? response['displayName'] ?? 'Usuario',
        'photoUrl': response['photo_url'] ?? response['photoUrl'] ?? '',
      };
    } catch (e) {
      print('=== ERROR EN getPublicUser ===');
      print(e);
      return {
        'id': uid,
        'displayName': 'Usuario',
        'photoUrl': '',
      };
    }
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userPublicProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getPublicUser(uid);
});
