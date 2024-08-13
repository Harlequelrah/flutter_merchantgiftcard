import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
export 'authentication_service.dart';
import 'home.dart';
import 'main.dart';

Future<void> login(String email, String password, BuildContext context) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez remplir tous les champs.')),
    );
    return;
  }

  final url = Uri.parse('http://192.168.0.113:5107/api/User/login');
  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];
        final Map<String, String> claims = parseJwt(token);

        final String role = claims['role'] ?? '';
        final String isActive = claims['IsActive'] ?? '';

        if (role != 'MERCHANT') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous n\'êtes pas autorisé à vous connecter à cette application.')),
          );
          return;
        }

        if (isActive.toLowerCase() == 'false') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Votre compte n\'est plus actif. Merci de contacter le support de GoChap.')),
          );
          return;
        }

        await _saveToken(token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion. Token invalide.')),
        );

      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la connexion. Vérifiez vos informations.')),
      );

    }
  } catch (e) {
    print('Erreur: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur de connexion. Veuillez réessayer.')),
    );

  }
}


Future<void> refreshToken(String refreshToken) async {
  final url = Uri.parse('http://192.168.0.113:5107/api/User/refresh-token');

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String newToken = responseData['token'];
      await _saveToken(
          newToken); // Mettre à jour le token dans SharedPreferences
    } else {
      print('Failed to refresh token.');
    }
  } catch (e) {
    print('Erreur: $e');
  }
}

Future<void> _saveToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<void> register(String email, String password, String nomComplet,
    String adresse, String telephone, BuildContext context) async {
  final url = Uri.parse('http://192.168.0.113:5107/api/User/register/user');

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez remplir tous les champs.')),
    );
    return;
  }

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'telephone': telephone,
        'adresse': adresse,
        'nomComplet': nomComplet,
      }),
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];
        await _saveToken(token); // Sauvegarde du token dans SharedPreferences

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie')),
        );

        await login(email, password, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Inscription réussie, mais token manquant ou invalide.')),
        );
      }
    } else {
      String errorMessage =
          'Échec de l\'inscription. Code: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur d\'inscription: ${e.toString()}')),
    );
  }

}
Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
Map<String, String> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('JWT invalide');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decodedBytes = base64Url.decode(normalized);
  final Map<String, dynamic> decodedMap = jsonDecode(utf8.decode(decodedBytes));

  return decodedMap.map((key, value) => MapEntry(key, value.toString()));
}
String? getClaimValue(String token, String key) {
  final parsedToken = parseJwt(token);
  return parsedToken[key];
}
