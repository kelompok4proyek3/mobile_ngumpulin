// lib/features/home/services/kategori_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class KategoriApiService {
  final Dio _dio = ApiClient.createDio();

  Map<String, dynamic> _toMap(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': fallback};
  }

  // GET /api/kategoris
  Future<Map<String, dynamic>> getKategoris() async {
    try {
      final response = await _dio.get('/kategoris');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}