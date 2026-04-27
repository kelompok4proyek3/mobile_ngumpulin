import '../../../core/network/api_client.dart';
import '../../../models/recommendation_model.dart';

class RecommendationApiService {
  final _dio = ApiClient.createDio();

  // GET /api/recommendations
  Future<List<RecommendationModel>> getRecommendations() async {
    final response = await _dio.get('/recommendations');
    final body = response.data;

    if (body['success'] == true) {
      final data = List<Map<String, dynamic>>.from(body['data']);
      return data.map((e) => RecommendationModel.fromJson(e)).toList();
    }

    throw Exception(body['message'] ?? 'Gagal mengambil rekomendasi');
  }

  // POST /api/recommendations/refresh
  Future<String> refreshRecommendations() async {
    final response = await _dio.post('/recommendations/refresh');
    return response.data['message'] ?? 'Sedang diperbarui...';
  }
}