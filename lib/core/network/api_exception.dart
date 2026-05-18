import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({this.statusCode, required this.message});

  factory ApiException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Koneksi timeout, coba lagi.');
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Tidak bisa konek ke server.');
      default:
        final code = e.response?.statusCode;
        final msg  = e.response?.data?['message'] ?? 'Terjadi kesalahan.';
        return ApiException(statusCode: code, message: msg);
    }
  }

  @override
  String toString() => message;
}