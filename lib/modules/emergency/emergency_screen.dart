import 'dart:async';
import 'package:flutter/material.dart';
import './widgets/emergency_confirm.dart';
import '../../shared/services/recording_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  int _secondsRemaining = 10;
  late Timer _timer;
  bool _isCancelled = false;
  late AnimationController _animationController;
  late Animation<double> _countdownScale;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Animation controller for countdown number scale
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Countdown scale animation
    _countdownScale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_animationController);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && !_isCancelled) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        if (!_isCancelled) {
          _triggerEmergency();
        }
      }
    });
  }

  void _triggerEmergency() {
    final recorder = RecordingService();
    recorder.recordFor30Seconds();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyConfirmedScreen()),
    );
  }

  void _cancelTimer() {
    setState(() {
      _isCancelled = true;
    });
    _timer.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark; // Verifica o modo escuro

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cuenta regresiva para emergencia',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _countdownScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _countdownScale.value,
                  child: Text(
                    '$_secondsRemaining',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color:
                          _secondsRemaining > 5
                              ? Colors.greenAccent
                              : Colors.redAccent,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _cancelTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _secondsRemaining > 5
                        ? Colors.greenAccent
                        : Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Cancelar Emergencia',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
