import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fake_async/fake_async.dart';
import 'package:bullying/shared/services/notification_service.dart';
import 'package:bullying/shared/services/recording_service.dart';

class InitializationSettingsFake extends Fake
    implements InitializationSettings {}

class NotificationDetailsFake extends Fake implements NotificationDetails {}

class MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockRecordingService extends Mock implements RecordingService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(InitializationSettingsFake());
    registerFallbackValue(NotificationDetailsFake());
  });
  late MockPlugin plugin;
  late MockRecordingService recordingService;
  late NotificationService service;

  setUp(() {
    plugin = MockPlugin();
    recordingService = MockRecordingService();
    when(() => recordingService.isRecording).thenReturn(false);
    service = NotificationService(recordingService, plugin);
    when(
      () => plugin.initialize(
        any(),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async {});
    when(
      () => plugin.show(
        any(),
        any(),
        any(),
        any(),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.cancel(0)).thenAnswer((_) async {});
  });

  test('cancelEmergency prevents timeout', () {
    bool triggered = false;
    fakeAsync((async) {
      service.init();
      async.flushMicrotasks();
      service.showEmergencyNotification(
        onTimeout: () {
          triggered = true;
        },
      );
      async.flushMicrotasks();
      service.cancelEmergency();
      async.elapse(const Duration(seconds: 6));
      expect(triggered, isFalse);
      verify(
        () => plugin.show(0, any(), any(), any(), payload: 'cancel_emergency'),
      ).called(1);
      verify(() => plugin.cancel(0)).called(1);
    });
  });

  test('onTimeout is called if not cancelled', () {
    bool triggered = false;
    fakeAsync((async) {
      service.init();
      async.flushMicrotasks();
      service.showEmergencyNotification(
        onTimeout: () {
          triggered = true;
        },
      );
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 6));
      expect(triggered, isTrue);
      verify(() => plugin.cancel(0)).called(greaterThanOrEqualTo(1));
    });
  });
  test('showEmergencyNotification does nothing when already recording', () {
    fakeAsync((async) {
      when(() => recordingService.isRecording).thenReturn(true);
      service.init();
      async.flushMicrotasks();
      service.showEmergencyNotification(onTimeout: () {});
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 6));
      verifyNever(
        () => plugin.show(
          any(),
          any(),
          any(),
          any(),
          payload: any(named: 'payload'),
        ),
      );
    });
  });
test('showLowStorageWarning triggers notification', () async {
    await service.showLowStorageWarning();
    verify(() => plugin.show(1, any(), any(), any())).called(1);
  });
}