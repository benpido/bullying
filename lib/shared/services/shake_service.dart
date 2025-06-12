import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/routes/app_routes.dart';

class ShakeService {
  final GlobalKey<NavigatorState> navigatorKey;
  final double threshold; // g-force
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastTrigger;

  ShakeService({required this.navigatorKey, this.threshold = 2.7});

  void start() {
    _subscription = accelerometerEvents.listen(_handleEvent);
  }

  void _handleEvent(AccelerometerEvent event) {
    final gX = event.x / 9.80665;
    final gY = event.y / 9.80665;
    final gZ = event.z / 9.80665;
    final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce > threshold) {
      final now = DateTime.now();
      if (_lastTrigger == null || now.difference(_lastTrigger!) > const Duration(seconds: 2)) {
        _lastTrigger = now;
        navigatorKey.currentState?.pushNamed(AppRoutes.emergency);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}