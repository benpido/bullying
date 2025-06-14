import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/routes/app_routes.dart';
import 'package:flutter/foundation.dart';

class ShakeService {
  final GlobalKey<NavigatorState>? navigatorKey;
  final double threshold; // g-force
  final void Function()? onTrigger;
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastTrigger;
  bool _hasTriggered = false;
  Timer? _resetTimer;

  ShakeService({this.navigatorKey, this.threshold = 2.7, this.onTrigger});

  void start() {
    _hasTriggered = false;
    _resetTimer?.cancel();
    _subscription = accelerometerEvents.listen(_handleEvent);
  }

  void _handleEvent(AccelerometerEvent event) {
    final gX = event.x / 9.80665;
    final gY = event.y / 9.80665;
    final gZ = event.z / 9.80665;
    final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (!_hasTriggered && gForce > threshold) {
      final now = DateTime.now();
      if (_lastTrigger == null || now.difference(_lastTrigger!) > const Duration(seconds: 2)) {
        _hasTriggered = true;
        _resetTimer?.cancel();
        _resetTimer = Timer(const Duration(seconds: 10), () {
          _hasTriggered = false;
        });
        if (onTrigger != null) {
          onTrigger!();
        } else {
          navigatorKey?.currentState?.pushNamed(AppRoutes.emergency);
        }
      }
    }
  }
  @visibleForTesting
  void handleAccelerometerEvent(AccelerometerEvent event) => _handleEvent(event);
  
  void dispose() {
    _subscription?.cancel();
  }
}