import '../../../core/network/api_client.dart';

class PreferenceApiService {
  final _dio = ApiClient.createDio();

  // GET /api/preferences
  Future<Map<String, dynamic>> getAllPreferences() async {
    final response = await _dio.get('/preferences');
    return response.data;
  }

  // GET /api/preferences/user
  Future<Map<String, dynamic>> getUserPreferences() async {
    final response = await _dio.get('/preferences/user');
    return response.data;
  }

  // POST /api/preferences/user
  Future<Map<String, dynamic>> syncUserPreferences(List<int> preferenceIds) async {
    final response = await _dio.post(
      '/preferences/user',
      data: {'preference_ids': preferenceIds},
    );
    return response.data;
  }

  // DELETE /api/preferences/user
  Future<Map<String, dynamic>> deleteUserPreferences() async {
    final response = await _dio.delete('/preferences/user');
    return response.data;
  }
}