import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/widgets.dart';
import 'noise_service.dart';
import 'shake_service.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  final noiseService =
      NoiseService(onTrigger: () => service.invoke('emergency'));
  final shakeService =
      ShakeService(onTrigger: () => service.invoke('emergency'));

  await noiseService.start();
  shakeService.start();

  service.on('stopService').listen((event) {
    noiseService.dispose();
    shakeService.dispose();
    service.stopSelf();
  });
}
