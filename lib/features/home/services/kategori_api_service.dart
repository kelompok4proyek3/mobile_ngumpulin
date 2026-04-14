// lib/features/home/services/kategori_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class KategoriApiService {
  final Dio _dio = ApiClient.createDio();

  // GET /api/kategoris
  Future<Map<String, dynamic>> getKategoris() async {
    try {
      final response = await _dio.get('/kategoris');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}