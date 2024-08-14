import 'models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://192.168.0.113:5107/api';

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

  static Future<String> ProcessPayement(String accessToken, String id , String beneficiaryToken, double montant) async {
    final String url = '$baseUrl/Merchant/processpayement/bymerchant/$id';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'token': beneficiaryToken,
        'montant':montant,
      }),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['token'];
    } else {
      throw Exception('Failed to load QRCodeToken');
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
