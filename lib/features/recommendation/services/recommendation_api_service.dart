import '../../../core/network/api_client.dart';
import '../../../models/recommendation_model.dart';

class RecommendationApiService {
  final _dio = ApiClient.createDio();

  // GET /api/recommendations
  Future<List<RecommendationModel>> getRecommendations() async {
    final response = await _dio.get('/recommendations');
    final body = response.data;

    // Server pakai { "status": "ok" | "pending", "data": [...] }
    final status = body['status'];

    if (status == 'ok') {
      final data = List<Map<String, dynamic>>.from(body['data']);
      return data.map((e) => RecommendationModel.fromJson(e)).toList();
    }

    if (status == 'pending') {
      // Rekomendasi sedang disiapkan, kembalikan list kosong
      // UI bisa polling ulang atau tampilkan pesan loading
      return [];
    }

    throw Exception(body['message'] ?? 'Gagal mengambil rekomendasi');
  }

  // POST /api/recommendations/refresh
  Future<String> refreshRecommendations() async {
    final response = await _dio.post('/recommendations/refresh');
    return response.data['message'] ?? 'Sedang diperbarui...';
  }
}