import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api"; 
  // Android emulator: 10.0.2.2
  // iOS simulator / Web / Desktop: localhost

  /////////////////////// USERS ///////////////////////

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load users");
  }

  Future<Map<String,dynamic>> addUser({
    required String name,
    required String email,
    required String passwordHash,
    String? phone,
    String? address,
    required String role, // donor or receiver
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password_hash": passwordHash,
        "phone": phone,
        "address": address,
        "role": role
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add user");
  }

  /////////////////////// NGOS ///////////////////////

  Future<List<dynamic>> getNgos() async {
    final response = await http.get(Uri.parse('$baseUrl/ngos'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load NGOs");
  }

  Future<Map<String,dynamic>> addNgo({
    required String ngoName,
    required String email,
    required String passwordHash,
    String? phone,
    String? address,
    String? licenseDoc,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ngos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ngo_name": ngoName,
        "email": email,
        "password_hash": passwordHash,
        "phone": phone,
        "address": address,
        "license_doc": licenseDoc
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add NGO");
  }

  /////////////////////// FOOD DONATIONS ///////////////////////

  Future<List<dynamic>> getFoodDonations() async {
    final response = await http.get(Uri.parse('$baseUrl/fooddonations'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load food donations");
  }

  Future<Map<String,dynamic>> addFoodDonation({
    required int userId,
    int? ngoId,
    required String foodType,
    required String quantity,
    required String pickupAddress,
    required String expiryTime, // "YYYY-MM-DD HH:MM:SS"
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fooddonations'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "ngo_id": ngoId,
        "food_type": foodType,
        "quantity": quantity,
        "pickup_address": pickupAddress,
        "expiry_time": expiryTime
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add food donation");
  }

  /////////////////////// REQUESTS ///////////////////////

  Future<List<dynamic>> getRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/requests'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load requests");
  }

  Future<Map<String,dynamic>> addRequest({
    required int userId,
    required String foodType,
    required String quantity,
    required String deliveryAddress,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "food_type": foodType,
        "quantity": quantity,
        "delivery_address": deliveryAddress
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add request");
  }

  /////////////////////// TRANSACTIONS ///////////////////////

  Future<List<dynamic>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load transactions");
  }

  Future<Map<String,dynamic>> addTransaction({
    required int donationId,
    required int requestId,
    required int ngoId,
    required String status, // allocated, picked_up, delivered
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "donation_id": donationId,
        "request_id": requestId,
        "ngo_id": ngoId,
        "status": status
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add transaction");
  }

  /////////////////////// FEEDBACK ///////////////////////

  Future<List<dynamic>> getFeedback() async {
    final response = await http.get(Uri.parse('$baseUrl/feedback'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load feedback");
  }

  Future<Map<String,dynamic>> addFeedback({
    required int userId,
    required int ngoId,
    required int rating, // 1 to 5
    String? comments,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "ngo_id": ngoId,
        "rating": rating,
        "comments": comments
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add feedback");
  }

  /////////////////////// ADMINS ///////////////////////

  Future<List<dynamic>> getAdmins() async {
    final response = await http.get(Uri.parse('$baseUrl/admins'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load admins");
  }

  Future<Map<String,dynamic>> addAdmin({
    required String name,
    required String email,
    required String passwordHash,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admins'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password_hash": passwordHash,
        "phone": phone
      }),
    );
    if (response.statusCode == 201) return jsonDecode(response.body);
    throw Exception("Failed to add admin");
  }
}
