// lib/features/mylist/services/saved_spot_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SavedSpotApiService {
  final Dio _dio = ApiClient.createDio();

  // Guard: server kadang return String (HTML error page) bukan Map
  Map<String, dynamic> _toMap(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': fallback};
  }

  // GET /api/saved-spots
  Future<Map<String, dynamic>> getSavedSpots() async {
    try {
      final response = await _dio.get('/saved-spots');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET /api/saved-spots/check/{spotId}
  Future<bool> checkIsSaved(int spotId) async {
    try {
      final response = await _dio.get('/saved-spots/check/$spotId');
      final data = response.data;
      if (data is Map<String, dynamic>) return data['is_saved'] == true;
      return false;
    } on DioException catch (_) {
      return false;
    }
  }

  // POST /api/saved-spots
  Future<Map<String, dynamic>> saveSpot(int spotId, {String catatan = ''}) async {
    try {
      final response = await _dio.post('/saved-spots', data: {
        'spot_id': spotId,
        'catatan': catatan,
      });
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // DELETE /api/saved-spots/{spotId}
  Future<Map<String, dynamic>> deleteSavedSpot(int spotId) async {
    try {
      final response = await _dio.delete('/saved-spots/$spotId');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}