import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'recording_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final RecordingService _recordingService;

  NotificationService(
    this._recordingService, [
    FlutterLocalNotificationsPlugin? plugin,
  ]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Timer? _timer;
  Future<void> init() async {
    await Permission.notification.request();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'cancel_emergency') {
          cancelEmergency();
        }
      },
    );
  }

  Future<void> showEmergencyNotification({
    required VoidCallback onTimeout,
  }) async {
    if (_recordingService.isRecording) return;
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
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

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
  Future<void> showLowStorageWarning() async {
    const androidDetails = AndroidNotificationDetails(
      'storage_channel',
      'Storage',
      channelDescription: 'Storage warnings',
      playSound: false,
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: false);
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      1,
      'Espacio insuficiente',
      'No hay espacio para grabar audio',
      details,
    );
  }
  Future<void> showDispatchFailureNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'dispatch_failure_channel',
      'Dispatch Failures',
      channelDescription: 'Dispatch failures when offline',
      playSound: false,
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
    );
    const iosDetails = DarwinNotificationDetails(presentSound: false);
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      2,
      'Envío pendiente',
      'Los mensajes se enviarán cuando haya conexión',
      details,
    );
  }
}