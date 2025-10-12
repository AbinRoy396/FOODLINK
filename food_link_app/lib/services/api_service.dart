import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'offline_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/user_model.dart';
import '/models/donation_model.dart';
import '/models/request_model.dart';
import 'package:flutter/material.dart';

class ApiService {
  // Production API URL (Render deployment)
  // For local development, use: http://192.168.4.88:3000/api
  static const String baseUrl = "https://foodlink-1-1m4w.onrender.com/api"; // Production URL
  static const String _tokenKey = 'auth_token';
  static const int maxRetries = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Callback for session expiry
  static Function()? onSessionExpired;

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

  // Retry logic for API calls
  static Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        // Exponential backoff
        await Future.delayed(Duration(seconds: attempts));
        debugPrint('Retry attempt $attempts/$maxRetries');
      }
    }
    throw Exception('Max retries exceeded');
  }

  // Handle HTTP response with session check
  static void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Session expired
      clearToken();
      if (onSessionExpired != null) {
        onSessionExpired!();
      }
      throw Exception('Session expired. Please login again.');
    }
    
    if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    }
  }

  // Make HTTP request with timeout and retry
  static Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    String? body,
  }) async {
    return await _retryRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers)
              .timeout(requestTimeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body)
              .timeout(requestTimeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body)
              .timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      _handleResponse(response);
      return response;
    });
  }

  // Register User
  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? address,
    String? phone,
    String? description,
    int? familySize,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
        'address': address,
        'phone': phone,
      };

      // Add optional fields if provided
      if (description != null) requestBody['description'] = description;
      if (familySize != null) requestBody['familySize'] = familySize.toString();

      final response = await _makeRequest(
        method: 'POST',
        endpoint: '/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return {'user': UserModel.fromJson(data['user']), 'token': data['token']};
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
        throw Exception(error);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
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

      if (!await OfflineQueueService.isOnline()) {
        await OfflineQueueService.enqueue(OfflineOperation(
          type: OfflineOpType.createDonation,
          payload: {
            'foodType': foodType,
            'quantity': quantity,
            'pickupAddress': pickupAddress,
            'expiryTime': expiryTime,
          },
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ));
        // Return a local optimistic object
        return DonationModel(
          id: -DateTime.now().millisecondsSinceEpoch,
          donorId: -1,
          donorName: 'Current User',
          foodType: foodType,
          category: 'Other',
          quantity: quantity,
          description: '',
          expiryDate: expiryTime,
          pickupAddress: pickupAddress,
          status: 'Pending',
          createdAt: DateTime.now(),
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'food_type': foodType,
          'quantity': quantity,
          'pickup_address': pickupAddress,
          'expiry_time': expiryTime,
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
      if (token == null) {
        debugPrint('No token available');
        return []; // Return empty list instead of throwing
      }

      final response = await http.get(
        Uri.parse('$baseUrl/donations/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DonationModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to get donations: ${response.statusCode}');
        return []; // Return empty list on error
      }
    } catch (e) {
      debugPrint('Get user donations error: $e');
      return []; // Return empty list instead of rethrowing
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

      if (!await OfflineQueueService.isOnline()) {
        await OfflineQueueService.enqueue(OfflineOperation(
          type: OfflineOpType.createRequest,
          payload: {
            'foodType': foodType,
            'quantity': quantity,
            'address': address,
            'notes': notes,
          },
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        ));
        return RequestModel(
          id: -DateTime.now().millisecondsSinceEpoch,
          receiverId: -1,
          foodType: foodType,
          quantity: quantity,
          address: address,
          status: 'Requested',
          createdAt: DateTime.now().toIso8601String(),
        );
      }

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

  // Get All Donations (for map view)
  static Future<List<DonationModel>> getAllDonations() async {
    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('No token available');
        return []; // Return empty list instead of throwing
      }

      final response = await http.get(
        Uri.parse('$baseUrl/donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DonationModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to get all donations: ${response.statusCode}');
        return []; // Return empty list on error
      }
    } catch (e) {
      debugPrint('Get all donations error: $e');
      return []; // Return empty list instead of rethrowing
    }
  }

  // Sync offline queue
  static Future<void> syncOfflineQueue() async {
    await OfflineQueueService.drainQueue((op) async {
      try {
        switch (op.type) {
          case OfflineOpType.createDonation:
            await createDonation(
              foodType: op.payload['foodType'],
              quantity: op.payload['quantity'],
              pickupAddress: op.payload['pickupAddress'],
              expiryTime: op.payload['expiryTime'],
            );
            return true;
          case OfflineOpType.createRequest:
            await createRequest(
              foodType: op.payload['foodType'],
              quantity: op.payload['quantity'],
              address: op.payload['address'],
              notes: op.payload['notes'],
            );
            return true;
        }
      } catch (_) {
        return false;
      }
    });
  }

  // Register Donor
  static Future<Map<String, dynamic>?> registerDonor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    return await register(
      email: email,
      password: password,
      name: name,
      role: 'Donor',
      address: address,
      phone: phone,
    );
  }

  // Register NGO
  static Future<Map<String, dynamic>?> registerNGO({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String description,
  }) async {
    return await register(
      email: email,
      password: password,
      name: name,
      role: 'NGO',
      address: address,
      phone: phone,
      description: description,
    );
  }

  // Register Receiver
  static Future<Map<String, dynamic>?> registerReceiver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required int familySize,
  }) async {
    return await register(
      email: email,
      password: password,
      name: name,
      role: 'Receiver',
      address: address,
      phone: phone,
      familySize: familySize,
    );
  }
}