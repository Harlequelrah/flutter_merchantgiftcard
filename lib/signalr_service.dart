import 'dart:io';
import 'package:http/io_client.dart';
import 'package:signalr_core/signalr_core.dart';
import 'notification_service.dart';
import 'authentication_service.dart';

Future<HubConnection> connectToSignalR(NotificationService notificationService) async {
  final String? token = await getToken();

  if (token == null) {
    throw Exception("Token non trouvé. Assurez-vous que l'utilisateur est connecté.");
  }

  final connection = HubConnectionBuilder()
      .withUrl(
        'http://10.0.2.2:5107/notificationHub',
        HttpConnectionOptions(
          client: IOClient(
              HttpClient()..badCertificateCallback = (x, y, z) => true),
          accessTokenFactory: () async => token,
        ),
      )
      .build();

  connection.onclose((error) {
    print("SignalR connection closed with error: $error");
  });

  connection.onreconnected((connectionId) {
    print("SignalR reconnected with connectionId: $connectionId");
  });

  connection.onreconnecting((error) {
    print("SignalR reconnecting with error: $error");
  });

  try {
    await connection.start();
    print("SignalR connection started");

    connection.on('ReceiveMessage', (message) {
      print("Message reçu : ${message.toString()}");

      notificationService.showNotification(
        0,
        "Nouvelle Notification",
        message.toString(),
      );
    });

  } catch (e) {
    print("Error starting SignalR connection: $e");
  }

  return connection;
}
