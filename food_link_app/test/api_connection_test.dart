import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Check frontend can fetch food donations from backend', () async {
    final url = Uri.parse('http://10.0.2.2:3000/api/fooddonations'); // Android emulator
    final response = await http.get(url);

    expect(response.statusCode, 200); // Ensure request is successful

    final data = jsonDecode(response.body);
    print("Data from backend: $data");

    expect(data, isA<List>()); // Should return a list of donations
  });
}
