import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/core/network/api_client.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getPublicUser(String uid) async {
    try {
      final response = await _apiClient.get('/users/$uid/public');
      return response;
    } catch (e) {
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
