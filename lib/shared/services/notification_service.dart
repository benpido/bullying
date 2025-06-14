import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: (response) {
      if (response.payload == 'cancel_emergency') {
        cancelEmergency();
      }
    });
  }

  Future<void> showEmergencyNotification({required VoidCallback onTimeout}) async {
    _timer?.cancel();
    const androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency',
      channelDescription: 'Emergency alerts',
      playSound: false,
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: false);
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      0,
      'Modo Escucha activado',
      'La grabaci\u00f3n iniciar\u00e1 en 5 segundos',
      details,
      payload: 'cancel_emergency',
    );

    _timer = Timer(const Duration(seconds: 5), () {
      _plugin.cancel(0);
      onTimeout();
    });
  }

  void cancelEmergency() {
    _timer?.cancel();
    _plugin.cancel(0);
  }
}