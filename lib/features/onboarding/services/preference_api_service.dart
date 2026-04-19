import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class PreferenceApiService {
  final String _baseUrl = ApiClient.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _headers({String? token}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // GET /api/preferences
  Future<Map<String, dynamic>> getAllPreferences() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/preferences'),
      headers: _headers(),
    );
    return jsonDecode(response.body);
  }

  // GET /api/preferences/user
  Future<Map<String, dynamic>> getUserPreferences() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/preferences/user'),
      headers: _headers(token: token),
    );
    return jsonDecode(response.body);
  }

  // POST /api/preferences/user
  Future<Map<String, dynamic>> syncUserPreferences(
      List<int> preferenceIds) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/preferences/user'),
      headers: _headers(token: token),
      body: jsonEncode({'preference_ids': preferenceIds}),
    );
    return jsonDecode(response.body);
  }

  // DELETE /api/preferences/user
  Future<Map<String, dynamic>> deleteUserPreferences() async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/preferences/user'),
      headers: _headers(token: token),
    );
    return jsonDecode(response.body);
  }
}
