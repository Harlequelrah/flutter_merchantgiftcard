import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'merchant_service.dart';

class SellPage extends StatefulWidget {
  final String accessToken;
  final String idUser;
  final double montant;

  SellPage({
    required this.accessToken,
    required this.idUser,
    required this.montant,
  });

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vente'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('QR Code Scanné: $result'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _processPayment,
                          child: Text('Valider le paiement'),
                        ),
                      ],
                    )
                  : Text('Scanner un code QR'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
      });
    });
  }

  Future<void> _processPayment() async {
    if (result != null && result!.isNotEmpty) {
      try {
        final String response = await MerchantService.ProcessPayement(
          widget.accessToken,
          widget.idUser,
          result!,
          widget.montant,
        );

        // Affiche un message de succès ou fais quelque chose avec la réponse
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement réussi: $response')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du paiement: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun QR Code scanné')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
