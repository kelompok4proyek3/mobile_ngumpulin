import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class NotificationApiService {
  final Dio _dio = ApiClient.createDio();

  // GET /api/notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // PATCH /api/notifications/{id}/read
  Future<Map<String, dynamic>> markAsRead(int id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // PATCH /api/notifications/read-all
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _dio.patch('/notifications/read-all');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // DELETE /api/notifications/{id}
  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response = await _dio.delete('/notifications/$id');
      return response.data;
    } on DioException catch (e) {
      return _error(e);
    }
  }

  // POST /api/notifications/token
  // Dipanggil di AuthApiService.login() setelah dapat token
  Future<void> saveToken(String fcmToken) async {
    try {
      await _dio.post('/notifications/token', data: {'fcm_token': fcmToken});
    } on DioException catch (_) {
      // Gagal simpan token tidak perlu crash app
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