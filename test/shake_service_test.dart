import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';
import 'package:bullying/shared/services/shake_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('trigger not called twice within debounce', () {
    int count = 0;
    final service = ShakeService(threshold: 1.0, onTrigger: () => count++);
    final event = AccelerometerEvent(30, 30, 30, DateTime.now());
    fakeAsync((async) {
      service.handleAccelerometerEvent(event);
      async.elapse(const Duration(milliseconds: 100));
      service.handleAccelerometerEvent(event);
      expect(count, 1);
      async.elapse(const Duration(seconds: 11));
      service.handleAccelerometerEvent(event);
      expect(count, 2);
    });
  });
}