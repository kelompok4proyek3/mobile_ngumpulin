// lib/features/detail/services/rating_api_service.dart
//
// Terhubung ke Laravel RatingController:
//   GET    /api/spots/{id}/ratings      → getRatingsBySpot()
//   POST   /api/spots/{id}/ratings      → storeOrUpdate()
//   GET    /api/spots/{id}/ratings/my   → getMyRating()
//   DELETE /api/spots/{id}/ratings      → deleteMyRating()
//   GET    /api/ratings/my              → getMyAllRatings()

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RatingApiService {
  final Dio _dio = ApiClient.createDio();

  // ── GET /spots/{spotId}/ratings ─────────────────────────────────────────
  // Dipakai di DetailScreen untuk tampilkan distribusi bintang + daftar ulasan
  Future<Map<String, dynamic>> getRatingsBySpot(int spotId) async {
    try {
      final response = await _dio.get('/spots/$spotId/ratings');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── POST /spots/{spotId}/ratings ────────────────────────────────────────
  // Kirim rating (1-5 bintang). Kalau sudah pernah → otomatis update.
  Future<Map<String, dynamic>> submitRating(int spotId, int score) async {
    try {
      final response = await _dio.post(
        '/spots/$spotId/ratings',
        data: {'score': score},
      );
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // ── GET /spots/{spotId}/ratings/my ─────────────────────────────────────
  // Cek apakah user sudah rating spot ini (untuk pre-fill bintang di dialog)
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
  // Semua rating yang pernah dikirim user yang login
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