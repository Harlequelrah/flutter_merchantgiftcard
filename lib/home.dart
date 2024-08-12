import 'package:flutter/material.dart';
import 'main.dart';
import 'authentication_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late String accessToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _fetchData() async {}

  Future<void> _loadTokenAndData() async {
    final String? token = await getToken();
    if (token != null) {
      setState(() {
        accessToken = token;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GiftCard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenue sur GoChap!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange[900],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
