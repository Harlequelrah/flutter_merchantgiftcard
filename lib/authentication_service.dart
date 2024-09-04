import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
export 'authentication_service.dart';
import 'merchant_service.dart';
import 'models.dart';
import 'home.dart';
import 'main.dart';

Future<void> login(String email, String password, BuildContext context) async {
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez remplir tous les champs.')),
    );
    return;
  }
    if (!isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('L\'email est invalide.')),
    );
    return;
  }
  email = email.trim();
  password = password.trim();

  final url = Uri.parse('https://10.0.2.2:7168/api/User/login');
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
    if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Votre accès a été refusé . Merci de contacter le support de GoChap.')),
      );
      return;
    }
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La connexion a echoué ;Veuillez verifier vos identifiants.')),
      );
      return;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];
        final Map<String, String> claims = parseJwt(token);
        // final String id = claims['nameid'] ?? '';
        final String role = claims['role'] ?? '';

        if (role != 'MERCHANT') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Vous n\'êtes pas autorisé à vous connecter à cette application.')),
          );
          return;
        }

        await _saveToken(token);
        await GetMerchantUser(context, token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Échec de la connexion. Token invalide.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Échec de la connexion. Vérifiez vos informations.')),
      );
      print('email : ${email},password : ${password}');
      print('Response body: ${response.body}');
      print('Response code: ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur de connexion. Veuillez réessayer.')),
    );
  }
}

Future<void> GetMerchantUser(BuildContext context, String token) async {
  try {
    final id = getClaimValue(token, "nameid") ?? "";
    final MerchantUser fetchedmerchant =
        await MerchantService.fetchMerchantUser(token, id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(merchant: fetchedmerchant)),
    );
  } catch (e) {
    print('Failed to load merchant $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Erreur lors du chargement de votre profil , Veuillez réessayer ultérieurement.')),
    );
  }
}
bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  return emailRegex.hasMatch(email);
}
bool isTokenExpired(String token) {
  final String? expirationClaim = getClaimValue(token, 'exp');
  if (expirationClaim == null) {
    throw Exception('Le token ne contient pas de claim "exp".');
  }

  final int expirationTimestamp = int.parse(expirationClaim);
  final DateTime expirationDate =
      DateTime.fromMillisecondsSinceEpoch(expirationTimestamp * 1000);

  return DateTime.now().isAfter(expirationDate);
}

Future<void> refreshToken(String token) async {
  final url = Uri.parse('https://10.0.2.2:7168/api/User/refresh-token');

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refreshToken': token,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String newToken = responseData['token'];
      await _saveToken(
          newToken);
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

Future<void> register(String email, String password, String nom, String prenom,
    String adresse, String telephone, BuildContext context) async {
  final url = Uri.parse('https://10.0.2.2:7168/api/User/register/merchant');

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
        'email': email.trim(),
        'password': password.trim(),
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'telephone': telephone.trim(),
        'adresse': adresse.trim()
      }),
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('token') &&
          responseData['token'] != null &&
          responseData['token'] is String) {
        final String token = responseData['token'];
        await _saveToken(token);

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

Future<void> loadTokenState() async {
  final String? token = await getToken();
  if (token != null) {
    if (isTokenExpired(token)) {
      await refreshToken(token);
    }
  }
}
