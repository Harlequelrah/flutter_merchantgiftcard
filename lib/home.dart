import 'package:flutter/material.dart';
import 'main.dart';
import 'authentication_service.dart';
import 'models.dart';
import 'history_page.dart';
import 'sell_page.dart';
import 'signalr_service.dart';
import 'notification_service.dart';
class HomePage extends StatefulWidget {
  final MerchantUser merchant;
  const HomePage({super.key, required this.merchant});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late MerchantUser merchant;
  late String accessToken;
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    merchant = widget.merchant;
    _loadToken();
    notificationService = NotificationService();
    notificationService.init();
  }

  Future<void> _loadToken() async {
    final String? token = await getToken();
    if (token != null) {
      setState(() {
        accessToken = token;
      });
      await connectToSignalR(context,notificationService);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<double?> _showMontantDialog(BuildContext context) async {
    TextEditingController montantController = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrer le montant'),
          content: TextField(
            controller: montantController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Montant'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final montant = double.tryParse(montantController.text);
                Navigator.of(context).pop(montant);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              color: Colors.orange[900],
              size: 30,
            ),
          ),
        ),
        title: Image.asset('assets/gochaplogo.png', height: 20),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.orange[900]),
            onPressed: () async {
              await logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.nomComplet,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          merchant.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.white54,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          merchant.solde,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.account_balance_wallet,
                                color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              "solde",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildFeatureButton(
                    icon: Icons.history,
                    label: 'Historique',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(
                              idMerchant: merchant.idMerchant.toString()),
                        ),
                      );
                    },
                  ),
                  _buildFeatureButton(
                    icon: Icons.sell,
                    label: 'Payement Par Carte Cadeau',
                    onTap: () async {
                      final double? montant = await _showMontantDialog(context);
                      if (montant != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellPage(
                              accessToken: accessToken,
                              idMerchant: merchant.idMerchant.toString(),
                              montant: montant,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orange[900]),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
