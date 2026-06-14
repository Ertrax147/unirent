import '../../../../core/network/api_client.dart';
import '../../domain/entities/aviso_arriendo_entity.dart';

class AvisoArriendoRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<AvisoArriendoEntity>> getAllAvisos() async {
    try {
      final response = await _apiClient.get('/avisos');
      print('=== RAW AVISOS ===');
      print(response);
      
      if (response is List) {
        return response.map((json) => AvisoArriendoEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching avisos from Spring Boot: $e');
    }
  }

  Future<AvisoArriendoEntity> getAvisoById(String id) async {
    try {
      final response = await _apiClient.get('/avisos/$id');
      return AvisoArriendoEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching aviso by ID: $e');
    }
  }

  Future<AvisoArriendoEntity> createAviso(Map<String, dynamic> avisoData) async {
    try {
      final response = await _apiClient.post('/avisos', avisoData);
      return AvisoArriendoEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error creating aviso: $e');
    }
  }
}
