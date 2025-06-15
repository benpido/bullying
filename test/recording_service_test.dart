import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:fake_async/fake_async.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:bullying/shared/services/recording_service.dart';

class RecordConfigFake extends Fake implements RecordConfig {}

class FakePathProviderPlatform extends PathProviderPlatform with Fake {
  @override
  Future<String?> getTemporaryPath() async => '/tmp';
}

class MockRecorder extends Mock implements AudioRecorder {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(RecordConfigFake());
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });
  int startCount = 0;
  late MockRecorder recorder;
  late RecordingService service;
  late double freeSpace;


  setUp(() {
    recorder = MockRecorder();
    freeSpace = 10;
    service = RecordingService(
      recorder: recorder,
      duration: const Duration(seconds: 1),
      freeSpaceProvider: (_) async => freeSpace,
    );
    when(() => recorder.isRecording()).thenAnswer((_) async => false);
    when(() => recorder.hasPermission()).thenAnswer((_) async => true);
    startCount = 0;
    when(() => recorder.start(any(), path: any(named: 'path'))).thenAnswer((
      _,
    ) async {
      startCount++;
    });
    when(() => recorder.stop()).thenAnswer((_) async {});
  });

  test('recording only starts once', () {
    fakeAsync((async) {
      service.recordFor30Seconds();
      async.flushMicrotasks();
      when(() => recorder.isRecording()).thenAnswer((_) async => true);
      service.recordFor30Seconds();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(startCount, 1);
      verify(() => recorder.stop()).called(1);
    });
  });
  test('recording aborts when storage is low', () {
    fakeAsync((async) {
      freeSpace = 0.5; // less than required 1MB
      bool warned = false;
      service.recordFor30Seconds(
        onInsufficientStorage: () {
          warned = true;
        },
      );
      async.flushMicrotasks();
      expect(startCount, 0);
      expect(warned, isTrue);
    });
  });

  test('recording starts when storage is sufficient', () {
    fakeAsync((async) {
      freeSpace = 5;
      service.recordFor30Seconds();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(startCount, 1);
    });
  });
}