import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../core/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NoiseService {
  final GlobalKey<NavigatorState>? navigatorKey;
  final double decibelThreshold;
  final void Function()? onTrigger;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;
  DateTime? _lastTrigger;
  bool _hasTriggered = false;
  Timer? _resetTimer;
  final ValueNotifier<double> currentDb = ValueNotifier<double>(0);

  NoiseService({
    this.navigatorKey,
    this.decibelThreshold = 80.0,
    this.onTrigger,
  });

  Future<void> start() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    _noiseMeter = NoiseMeter();
    _hasTriggered = false;
    _resetTimer?.cancel();
    currentDb.value = 0;
    try {
      _subscription =
          _noiseMeter!.noise.listen(_onData, onError: onError);
    } catch (_) {}
  }

  void _onData(NoiseReading reading) {
    currentDb.value = reading.meanDecibel;
    if (!_hasTriggered && reading.meanDecibel >= decibelThreshold) {
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
        _lastTrigger = now;
      }
    }
  }
  
  @visibleForTesting
  void handleNoiseReading(NoiseReading reading) => _onData(reading);
  void onError(Object error) {}

  void dispose() {
    _subscription?.cancel();
    currentDb.dispose();
  }
}