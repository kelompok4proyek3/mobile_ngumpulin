// lib/features/home/services/spot_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SpotApiService {
  final Dio _dio = ApiClient.createDio();

  // GET /api/spots
  Future<Map<String, dynamic>> getSpots({
    String? search,
    String? kategori,
  }) async {
    try {
      final response = await _dio.get('/spots', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.',
      };
    }
  }

  // GET /api/spots/{id}
  Future<Map<String, dynamic>> getSpotDetail(int id) async {
    try {
      final response = await _dio.get('/spots/$id');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.',
      };
    }
  }
}