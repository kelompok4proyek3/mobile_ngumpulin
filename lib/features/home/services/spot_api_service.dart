// lib/features/home/services/spot_api_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SpotApiService {
  final Dio _dio = ApiClient.createDio();

  Map<String, dynamic> _toMap(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': fallback};
  }

  // GET /api/spots — support search, filter kategori, dan sort
  Future<Map<String, dynamic>> getSpots({
    String? search,
    String? kategori,
    String? sort,
  }) async {
    try {
      final response = await _dio.get('/spots', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      });
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET /api/spots/{id}
  Future<Map<String, dynamic>> getSpotDetail(int id) async {
    try {
      final response = await _dio.get('/spots/$id');
      return _toMap(response.data, 'Format response tidak valid.');
    } on DioException catch (e) {
      if (e.response != null) return _toMap(e.response!.data, 'Server error.');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}