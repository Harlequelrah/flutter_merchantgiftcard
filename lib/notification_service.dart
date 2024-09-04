import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await requestPermission();
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      print('La plateforme est iOS');
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      if (granted == true) {
        print('Notification permission granted on iOS');
      } else {
        print('Notification permission denied on iOS');
      }
    } else if (Platform.isAndroid) {
      print('La plateforme est Android');
      // Demander la permission pour afficher les notifications
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permission granted on Android');
      } else {
        print('Notification permission denied on Android');
      }
    } else {
      print('La plateforme n\'est ni iOS ni Android');
    }
  }

  Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '5107',
      'GoChapGiftCard',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
      print("Notification affichée avec succès.");
    } catch (e) {
      print("Erreur lors de l'affichage de la notification : $e");
    }
  }
}
