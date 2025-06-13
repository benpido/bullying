import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../core/routes/app_routes.dart';

class NoiseService {
  final GlobalKey<NavigatorState> navigatorKey;
  final double decibelThreshold;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;
  DateTime? _lastTrigger;
  bool _hasTriggered = false;
  Timer? _resetTimer;

  NoiseService({
    required this.navigatorKey,
    this.decibelThreshold = 85.0,
  });

  void start() {
    _noiseMeter = NoiseMeter();
    _hasTriggered = false;
    _resetTimer?.cancel();
    try {
      _subscription =
          _noiseMeter!.noise.listen(_onData, onError: onError);
    } catch (_) {}
  }

  void _onData(NoiseReading reading) {
    if (!_hasTriggered && reading.meanDecibel >= decibelThreshold) {
      final now = DateTime.now();
      if (_lastTrigger == null || now.difference(_lastTrigger!) > const Duration(seconds: 2)) {
        _hasTriggered = true;
        _resetTimer?.cancel();
        _resetTimer = Timer(const Duration(seconds: 10), () {
          _hasTriggered = false;
        });
        navigatorKey.currentState?.pushNamed(AppRoutes.emergency);
        _lastTrigger = now;
      }
    }
  }

  void onError(Object error) {}

  void dispose() {
    _subscription?.cancel();
  }
}