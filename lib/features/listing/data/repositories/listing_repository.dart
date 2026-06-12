import '../../../../core/network/api_client.dart';
import '../../domain/entities/listing_entity.dart';

class ListingRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<ListingEntity>> getAllListings() async {
    try {
      final response = await _apiClient.get('/listings');
      
      if (response is List) {
        return response.map((json) => ListingEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching listings from Spring Boot: $e');
    }
  }

  Future<ListingEntity> createListing(Map<String, dynamic> listingData) async {
    try {
      final response = await _apiClient.post('/listings', listingData);
      return ListingEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error creating listing: $e');
    }
  }
}
