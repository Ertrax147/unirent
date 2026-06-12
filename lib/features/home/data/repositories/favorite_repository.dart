import '../../../../core/network/api_client.dart';

class FavoriteRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<int>> getFavorites() async {
    try {
      final response = await _apiClient.get('/favorites');
      if (response is List) {
        return response.map((json) => json['listingId'] as int).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  Future<void> addFavorite(int listingId) async {
    try {
      await _apiClient.post('/favorites/$listingId', {});
    } catch (e) {
      throw Exception('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(int listingId) async {
    try {
      // Como ApiClient no tiene delete por defecto, usamos un POST a un endpoint o añadimos delete a ApiClient.
      // Wait, let's look at ApiClient. It doesn't have delete(). I need to add it, or use the flutter http directly, but let's add delete to ApiClient.
      // Wait, in this case I will use a custom http call or I will add delete to ApiClient. Let's add delete to ApiClient in the next step.
      await _apiClient.delete('/favorites/$listingId');
    } catch (e) {
      throw Exception('Error removing favorite: $e');
    }
  }
}
