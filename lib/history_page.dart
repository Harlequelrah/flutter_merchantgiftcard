import 'package:flutter/material.dart';
import 'merchant_service.dart';
import 'authentication_service.dart';
import 'models.dart';
import 'main.dart';

class HistoryPage extends StatefulWidget {
  final String idMerchant;
  const HistoryPage({Key? key, required this.idMerchant}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String accessToken;
  late String idMerchant;
  List<History> histories = [];

  @override
  void initState() {
    super.initState();
    idMerchant = widget.idMerchant;
    _loadTokenAndFetchHistories();
  }

  Future<void> _loadTokenAndFetchHistories() async {
    final String? token = await getToken();
    if (token != null) {
      setState(() {
        accessToken = token;
      });
      await _fetchHistories();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _fetchHistories() async {
    try {
      final List<History> fetchedHistories =
          await MerchantService.fetchHistories(accessToken, idMerchant);
      setState(() {
        histories = fetchedHistories;
      });
    } catch (e) {
      print('Failed to load histories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange[900]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Historique',
          style: TextStyle(color: Colors.orange[900]),
        ),
        centerTitle: true,
      ),
      body: histories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade900,
                        Colors.orange.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.action,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Montant: ${history.montant} XOF',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date: ${history.date}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
