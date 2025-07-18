import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:signalr_core/signalr_core.dart';
import 'notification_service.dart';
import 'authentication_service.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}


Future<HubConnection> connectToSignalR(BuildContext context,
    NotificationService notificationService) async {
  final String? token = await getToken();

  if (token == null) {
    throw Exception(
        "Token non trouvé. Assurez-vous que l'utilisateur est connecté.");
  }

  final connection = HubConnectionBuilder()
      .withUrl(
        'https://53sssvqg-7168.uks1.devtunnels.ms/notificationHub',
        HttpConnectionOptions(
          client: IOClient(),
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

    connection.on('ReceiveMessage', (message) async {
      String messageR = "";
      if (message != null && message.isNotEmpty) {
        messageR = message[0];
      }

      print("Message reçu : ${message.toString()}");
      notificationService.showNotification(
        0,
        "Nouvelle Notification",
        messageR.toString(),
      );
      await GetMerchantUser(context,token);
    });

  } catch (e) {
    print("Error starting SignalR connection: $e");
  }

  return connection;
}
