// lib/features/profile/services/profile_api_service.dart
//
// Service untuk komunikasi dengan ProfileController di Laravel.
// - getProfile()      → GET  /profile
// - updateProfile()   → POST /profile/update  (multipart jika ada foto)
// - updatePassword()  → POST /profile/password

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class ProfileApiService {
  final Dio _dio = ApiClient.createDio();

  // ─── GET /profile ───────────────────────────────────────────────────────────
  /// Fetch profil dari server & sinkronkan ke SharedPreferences.
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final data = response.data;

      if (data['success'] == true) {
        await _syncToPrefs(data['data']);
      }

      return data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── POST /profile/update ────────────────────────────────────────────────────
  /// Update nama, email, dan/atau foto profil.
  /// [photoFile] opsional — kirim File jika user ganti foto.
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    File? photoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        if (photoFile != null)
          'foto_profile': await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFile.path.split('/').last,
          ),
      });

      final response = await _dio.post('/profile/update', data: formData);
      final data = response.data;

      if (data['success'] == true) {
        await _syncToPrefs(data['data']);
      }

      return data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── POST /profile/password ──────────────────────────────────────────────────
  /// Ganti password. Backend mengembalikan success true/false + message.
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/profile/password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Tulis name, email, foto_profile ke SharedPreferences.
  /// Dipanggil setelah getProfile() dan updateProfile() sukses
  /// agar ProfileScreen selalu sinkron tanpa perlu fetch ulang.
  Future<void> _syncToPrefs(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData['name'] != null) {
      await prefs.setString('user_name', userData['name']);
    }
    if (userData['email'] != null) {
      await prefs.setString('user_email', userData['email']);
    }
    // foto_profile bisa null (user belum upload foto)
    final foto = userData['foto_profile'];
    if (foto != null) {
      await prefs.setString('user_avatar', foto);
    } else {
      await prefs.remove('user_avatar');
    }
  }

  Map<String, dynamic> _dioError(DioException e) {
    if (e.response != null) return e.response!.data;
    return {
      'success': false,
      'message': 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
    };
  }
}