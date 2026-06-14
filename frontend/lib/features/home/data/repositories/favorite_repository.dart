import '../../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';

class FavoriteRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<int>> getFavorites() async {
    try {
      final response = await _apiClient.get('/favorites');
      if (response is List) {
        return response.cast<int>();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  Future<void> addFavorite(int listingId) async {
    try {
      await _apiClient.post('/favorites/$listingId', {});
    } catch (e) {
      debugPrint('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(int listingId) async {
    try {
      await _apiClient.delete('/favorites/$listingId');
    } catch (e) {
      debugPrint('Failed to remove favorite: $e');
    }
  }
}
