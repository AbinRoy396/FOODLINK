import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // save token locally
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/login');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['token'] != null) await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register(Map<String, dynamic> user) async {
    final uri = Uri.parse('$baseUrl/api/register');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Register failed: ${resp.statusCode} ${resp.body}');
    }
  }

  // GET donations
  Future<List<dynamic>> getDonations() async {
    final uri = Uri.parse('$baseUrl/api/donations');
    final headers = await _headers();
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch donations: ${resp.statusCode}');
    }
  }

  // POST donation (requires auth)
  Future<Map<String, dynamic>> createDonation(
      Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/api/donations');
    final headers = await _headers();
    final resp = await http.post(uri, headers: headers, body: jsonEncode(body));
    if (resp.statusCode == 201) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Failed to create donation: ${resp.statusCode}');
    }
  }
}
