import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PreferenceApiService {
  final _dio = ApiClient.createDio();

  Map<String, dynamic> _toMap(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': fallback};
  }

  // GET /api/preferences
  Future<Map<String, dynamic>> getAllPreferences() async {
    try {
      final response = await _dio.get('/preferences');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET /api/preferences/user
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await _dio.get('/preferences/user');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // POST /api/preferences/user
  Future<Map<String, dynamic>> syncUserPreferences(List<int> preferenceIds) async {
    try {
      final response = await _dio.post(
        '/preferences/user',
        data: {'preference_ids': preferenceIds},
      );
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Gagal menyimpan preferensi.'};
    }
  }

  // DELETE /api/preferences/user
  Future<Map<String, dynamic>> deleteUserPreferences() async {
    try {
      final response = await _dio.delete('/preferences/user');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Gagal menghapus preferensi.'};
    }
  }
}