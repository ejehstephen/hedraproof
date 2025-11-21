import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  static Future<Map<String, dynamic>> mintReceipt({
    required String item,
    required int amount,
    required String userWalletAddress,
    required String appName,
    required String actionType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mint-receipt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'item': item,
          'amount': amount,
          'userWalletAddress': userWalletAddress,
          'appName': appName,
          'actionType': actionType,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
                return {'success': true, 'qrCodeIpfsCid': responseData['qrCodeIpfsCid'], 'tokenId': responseData['tokenId'], 'serial': responseData['serial'], 'timestamp': responseData['timestamp']};
      } else {
        return {'success': false, 'error': 'Failed to mint receipt'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyReceipt({
    required String tokenId,
    required int serial,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-receipt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tokenId': tokenId,
          'serial': serial,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'verified': false, 'error': 'Verification failed'};
      }
    } catch (e) {
      return {'verified': false, 'error': e.toString()};
    }
  }

  static Future<List<dynamic>> getReceipts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/receipts'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getOwnerReceipts(String accountId) async {
    try {
      final url = '$baseUrl/owner-receipts/$accountId';
      print('ApiService: Fetching owner receipts from: $url');
      final response = await http.get(Uri.parse(url));
      print('ApiService: Response status code for owner receipts: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
