import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiProvider {
  final String _baseUrl =
      "http://localhost:3000/api"; // Replace with your actual API endpoint

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (kDebugMode) {
      print('Login Response status: ${response.statusCode}');
      print('Login Response body: ${response.body}');
    }

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String walletAddress) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'walletAddress': walletAddress,
      }),
    );

    if (kDebugMode) {
      print('Register Response status: ${response.statusCode}');
      print('Register Response body: ${response.body}');
    }

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'Failed to register');
    }
  }

  // You can add other API calls here, for example:
  // Future<List<dynamic>> getReceipts(String token) async { ... }
  // Future<Map<String, dynamic>> createReceipt(String token, Map<String, dynamic> receiptData) async { ... }
}
