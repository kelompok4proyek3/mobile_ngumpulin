import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/recommendation_model.dart';
import 'package:dio/dio.dart';

class RecommendationApiService {
  final _dio = ApiClient.createDio();

  // GET /api/recommendations
Future<List<RecommendationModel>> getRecommendations() async {
  try {
    final response = await _dio.get('/recommendations');
    final body   = response.data;
    final status = body['status'];

    if (status == 'ok') {
      final data = List<Map<String, dynamic>>.from(body['data']);
      return data.map((e) => RecommendationModel.fromJson(e)).toList();
    }
    if (status == 'pending') return []; // UI mulai polling

    throw ApiException(message: body['message'] ?? 'Gagal mengambil rekomendasi.');
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  }
}
  // POST /api/recommendations/refresh
  Future<String> refreshRecommendations() async {
    final response = await _dio.post('/recommendations/refresh');
    return response.data['message'] ?? 'Sedang diperbarui...';
  }
}