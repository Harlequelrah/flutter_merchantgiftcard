import 'models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://192.168.43.49:7168/api';

class MerchantService {
  static Future<MerchantUser> fetchMerchantUser(
      String accessToken, String id) async {
    final String url = '$baseUrl/Merchant/User/$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      return MerchantUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load merchant');
    }
  }

  static Future<bool> ProcessPayement(String accessToken, String id,
      String beneficiaryToken, double montant) async {
    final String url = '$baseUrl/Merchant/processpayement/bymerchant/$id';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'token': beneficiaryToken,
        'montant': montant,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {

      String errorMessage = 'Failed to process payment';
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        if (errorResponse.containsKey('message')) {
          errorMessage = errorResponse['message'];
        }
      }
      throw Exception(errorMessage);
    }
  }

  static Future<List<History>> fetchHistories(
      String accessToken, String idMerchant) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Merchant/history/$idMerchant'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> historiesJson = jsonResponse['\$values'];
      return historiesJson.map((json) => History.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load histories');
    }
  }
}
