// lib/features/profile/services/profile_api_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class ProfileApiService {
  final Dio _dio = ApiClient.createDio();

  // ─── GET /auth/profile ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      final data = response.data;
      if (data['success'] == true) await _syncToPrefs(data['data']);
      return data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── POST /auth/profile/update ──────────────────────────────────────────────
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

      final response = await _dio.post('/auth/profile/update', data: formData);
      final data = response.data;
      if (data['success'] == true) await _syncToPrefs(data['data']);
      return data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── POST /auth/profile/password ────────────────────────────────────────────
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/profile/password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return response.data;
    } on DioException catch (e) {
      return _dioError(e);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Future<void> _syncToPrefs(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    if (userData['name'] != null) await prefs.setString('user_name', userData['name']);
    if (userData['email'] != null) await prefs.setString('user_email', userData['email']);
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