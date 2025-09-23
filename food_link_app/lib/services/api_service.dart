import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/models/user_model.dart';
import '/models/donation_model.dart';
import '/models/request_model.dart';
import 'package:flutter/material.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";
  static const String _tokenKey = 'auth_token';

  // Get stored token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Save token
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  // Clear token (logout)
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Register User
  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          'address': address,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return {'user': UserModel.fromJson(data['user']), 'token': data['token']};
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // Login User
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return {'user': UserModel.fromJson(data['user']), 'token': data['token']};
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  // Get Profile
  static Future<UserModel?> getProfile(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get profile';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Get profile error: $e');
      rethrow;
    }
  }

  // Create Donation
  static Future<DonationModel?> createDonation({
    required String foodType,
    required String quantity,
    required String pickupAddress,
    required String expiryTime,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.post(
        Uri.parse('$baseUrl/donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'foodType': foodType,
          'quantity': quantity,
          'pickupAddress': pickupAddress,
          'expiryTime': expiryTime,
        }),
      );

      if (response.statusCode == 201) {
        return DonationModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to create donation';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Create donation error: $e');
      rethrow;
    }
  }

  // Get User Donations - FIXED METHOD NAME
  static Future<List<DonationModel>> getUserDonations(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.get(
        Uri.parse('$baseUrl/donations/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DonationModel.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get donations';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Get user donations error: $e');
      rethrow;
    }
  }

  // Update Donation Status (NGO)
  static Future<DonationModel?> updateDonationStatus(int donationId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.put(
        Uri.parse('$baseUrl/donations/$donationId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return DonationModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to update donation status';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Update donation status error: $e');
      rethrow;
    }
  }

  // Create Request
  static Future<RequestModel?> createRequest({
    required String foodType,
    required String quantity,
    required String address,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'foodType': foodType,
          'quantity': quantity,
          'address': address,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return RequestModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to create request';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Create request error: $e');
      rethrow;
    }
  }

  // Get User Requests - FIXED METHOD NAME
  static Future<List<RequestModel>> getUserRequests(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.get(
        Uri.parse('$baseUrl/requests/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => RequestModel.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get requests';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Get user requests error: $e');
      rethrow;
    }
  }

  // Update Request Status (NGO)
  static Future<RequestModel?> updateRequestStatus(int requestId, String status) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token');

      final response = await http.put(
        Uri.parse('$baseUrl/requests/$requestId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return RequestModel.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to update request status';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Update request status error: $e');
      rethrow;
    }
  }
}