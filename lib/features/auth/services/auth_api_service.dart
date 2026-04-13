import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class AuthApiService {
  final Dio _dio = ApiClient.createDio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;

      if (data['success'] == true) {
        // Simpan token ke local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['data']['token']);
        await prefs.setString('user_name', data['data']['user']['name']);
        await prefs.setString('user_email', data['data']['user']['email']);
      }

      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data; // return error dari Laravel
      }
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // tetap lanjut hapus token meski API gagal
    }
  }

  // Tambahkan di dalam class AuthApiService, setelah method logout()

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'code': code,
      });
      final data = response.data;

      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['data']['token']);
        await prefs.setString('user_name', data['data']['user']['name']);
        await prefs.setString('user_email', data['data']['user']['email']);
      }

      return data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response =
          await _dio.post('/auth/resend-otp', data: {'email': email});
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
      };
    }
  }
}
