// lib/features/mylist/services/saved_spot_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SavedSpotApiService {
  final Dio _dio = ApiClient.createDio();

  // GET /api/saved-spots  → list saved spots milik user
  Future<Map<String, dynamic>> getSavedSpots() async {
    try {
      final response = await _dio.get('/saved-spots');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // DELETE /api/saved-spots/{spotId}  → hapus dari list
  Future<Map<String, dynamic>> deleteSavedSpot(int spotId) async {
    try {
      final response = await _dio.delete('/saved-spots/$spotId');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}