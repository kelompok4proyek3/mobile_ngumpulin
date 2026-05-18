// lib/features/detail/services/rating_api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RatingApiService {
  final Dio _dio = ApiClient.createDio();

  // ── GET /spots/{spotId}/ratings ─────────────────────────────────────────
  Future<Map<String, dynamic>> getRatingsBySpot(int spotId) async {
    try {
      final response = await _dio.get('/spots/$spotId/ratings');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── POST /spots/{spotId}/ratings ────────────────────────────────────────
  // score      → wajib
  // reviewText → opsional
  // fotos      → opsional, max 3 file, max 1MB per file (validasi di UI)
  Future<Map<String, dynamic>> submitRating(
    int spotId,
    int score, {
    String? reviewText,
    List<File>? fotos,
  }) async {
    try {
      final Map<String, dynamic> fields = {'score': score};

      if (reviewText != null && reviewText.isNotEmpty) {
        fields['review_text'] = reviewText;
      }

      // Kirim sebagai foto[0], foto[1], foto[2] — Laravel terima sebagai array
      if (fotos != null && fotos.isNotEmpty) {
        for (int i = 0; i < fotos.length; i++) {
          fields['foto[$i]'] = await MultipartFile.fromFile(
            fotos[i].path,
            filename: fotos[i].path.split('/').last,
          );
        }
      }

      final response = await _dio.post(
        '/spots/$spotId/ratings',
        data: FormData.fromMap(fields),
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── GET /spots/{spotId}/ratings/my ─────────────────────────────────────
  Future<Map<String, dynamic>> getMyRating(int spotId) async {
    try {
      final response = await _dio.get('/spots/$spotId/ratings/my');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── DELETE /spots/{spotId}/ratings ──────────────────────────────────────
  Future<Map<String, dynamic>> deleteMyRating(int spotId) async {
    try {
      final response = await _dio.delete('/spots/$spotId/ratings');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── GET /ratings/my ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMyAllRatings() async {
    try {
      final response = await _dio.get('/ratings/my');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Map<String, dynamic> _error(DioException e) {
    if (e.response != null) return e.response!.data;
    return {
      'success': false,
      'message': 'Tidak dapat terhubung ke server.',
    };
  }
}