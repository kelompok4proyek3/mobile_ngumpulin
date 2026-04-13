// lib/features/auth/services/google_auth_service.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class GoogleAuthService {
  final Dio _dio = ApiClient.createDio();

  // Ganti dengan Web Client ID dari Google Console
  static const String _webClientId = '1030940065041-g81pp48smu0iu98visnfbmgjkhmkgbc4.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign out dulu biar muncul account picker
      await _googleSignIn.signOut();

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return {'success': false, 'message': 'Login dibatalkan'};
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Gagal mendapatkan token Google'};
      }

      // Kirim idToken ke Laravel
      final response = await _dio.post('/auth/google', data: {
        'id_token': idToken,
      });

      final data = response.data;

      if (data['success'] == true) {
        await _saveSession(data['data']);
      }

      return data;

    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal login dengan Google: ${e.toString()}',
      };
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['token'] != null) {
      await prefs.setString('auth_token', data['token']);
    }
    final user = data['user'];
    if (user != null) {
      if (user['name'] != null) await prefs.setString('user_name', user['name']);
      if (user['email'] != null) await prefs.setString('user_email', user['email']);
      final foto = user['foto_profile'];
      if (foto != null) {
        await prefs.setString('user_avatar', foto);
      } else {
        await prefs.remove('user_avatar');
      }
    }
  }
}