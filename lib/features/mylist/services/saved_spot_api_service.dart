// lib/features/mylist/services/saved_spot_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SavedSpotApiService {
  final Dio _dio = ApiClient.createDio();

  // GET /api/saved-spots
  Future<Map<String, dynamic>> getSavedSpots() async {
    try {
      final response = await _dio.get('/saved-spots');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET /api/saved-spots/check/{spotId} → cek apakah spot sudah disimpan
  Future<bool> checkIsSaved(int spotId) async {
    try {
      final response = await _dio.get('/saved-spots/check/$spotId');
      return response.data['is_saved'] == true;
    } on DioException catch (_) {
      return false;
    }
  }

  // POST /api/saved-spots → simpan spot ke list
  Future<Map<String, dynamic>> saveSpot(int spotId, {String catatan = ''}) async {
    try {
      final response = await _dio.post('/saved-spots', data: {
        'spot_id': spotId,
        'catatan': catatan,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // DELETE /api/saved-spots/{spotId} → hapus dari list
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