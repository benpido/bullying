import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullying/shared/services/encryption_util.dart';
import 'package:bullying/shared/services/emergency_dispatch_service.dart';
import 'package:bullying/shared/services/contact_service.dart';
import 'package:bullying/shared/models/contact_model.dart';
import 'package:bullying/shared/services/notification_service.dart';
import 'test_helpers.dart';

class MockContactService extends Mock implements ContactService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContactService contactService;
  late FakeStorage storage;
  late List<String> sent;
  late FakeLogService logService;
  late MockNotificationService notificationService;

  setUp(() {
    contactService = MockContactService();
    storage = FakeStorage();
    sent = [];
    logService = FakeLogService();
    notificationService = MockNotificationService();
  });

  test('sends messages when online', () async {
    SharedPreferences.setMockInitialValues({});
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final service = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.wifi),
      logService: logService,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    await service.dispatch('data');
    expect(sent.length, 1);
    expect(storage.map.isEmpty, isTrue);
  });

  test('stores when offline and resends later', () async {
    SharedPreferences.setMockInitialValues({});
    final util = EncryptionUtil('test_key');
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final offline = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.none),
      logService: logService,
      encryption: util,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    await offline.dispatch('data');
    expect(sent.isEmpty, isTrue);
    expect(storage.map['pending'], isNotNull);
    final storedList = jsonDecode(storage.map['pending']!);
    final item = storedList.first as Map<String, dynamic>;
    final encMsg = item['message'] as String;

    expect(encMsg.contains('Audio: data'), isFalse);
    final decMsg = utf8.decode(offline.encryption.decrypt(encMsg));
    expect(decMsg, contains('Audio: data'));

    final online = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.mobile),
      logService: logService,
      encryption: util,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    await online.dispatch('data2');
    expect(sent.length, 2); // one from pending and one current
    expect(sent.any((s) => s.contains('Audio: data')), isTrue);
    expect(storage.map['pending'], isNull);
  });
  test('packages data correctly', () async {
    SharedPreferences.setMockInitialValues({
      'userName': 'Alice',
      'userPhoneNumber': '999',
    });
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final service = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 5.0, 'longitude': 6.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.wifi),
      logService: logService,
      sender: (n, m) async => sent.add(m),
    );
    await service.dispatch('audio');
    final message = sent.single;
    expect(message, contains('Nombre: Alice'));
    expect(message, contains('Teléfono: 999'));
    expect(message, contains('Ubicación: 5.0,6.0'));
    expect(message, contains('Audio: audio'));
    expect(message, contains('Fecha:'));
  });

  test('pending messages sent when connectivity changes', () async {
    SharedPreferences.setMockInitialValues({});
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final connectivity = StreamConnectivity(ConnectivityResult.none);
    final service = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: connectivity,
      logService: logService,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    service.startConnectivityMonitor();
    await service.dispatch('data');
    expect(sent.isEmpty, isTrue);
    connectivity.emit(ConnectivityResult.mobile);
    await Future.delayed(Duration.zero);
    expect(sent.length, 1);
    expect(storage.map['pending'], isNull);
    await connectivity.dispose();
  });


  test('queues offline and sends when back online', () async {
    SharedPreferences.setMockInitialValues({});
    final util = EncryptionUtil('test_key');
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final offline = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.none),
      logService: logService,
      encryption: util,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    await offline.dispatch('data');
    final stored = jsonDecode(storage.map['pending']!);
    expect(stored, isA<List>());
    final item = stored.first as Map<String, dynamic>;
    expect(item['numbers'], ['1']);
    final encMsg = item['message'] as String;
    expect(encMsg.contains('Audio: data'), isFalse);
    final decMsg = utf8.decode(offline.encryption.decrypt(encMsg));
    expect(decMsg, contains('Audio: data'));

    final online = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.mobile),
      logService: logService,
      encryption: util,
      sender: (n, m) async => sent.add('$n:$m'),
    );
    await online.dispatch('data2');
    expect(sent.length, 2);
    expect(sent.any((s) => s.contains('Audio: data')), isTrue);
    expect(storage.map['pending'], isNull);
  });
  test('log records success', () async {
    SharedPreferences.setMockInitialValues({});
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final service = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 3.0, 'longitude': 4.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.wifi),
      logService: logService,
      sender: (n, m) async {},
    );
    await service.dispatch('data');
    expect(logService.logs.single.success, isTrue);
  });

  test('log records failure', () async {
    SharedPreferences.setMockInitialValues({});
    when(
      () => contactService.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final service = EmergencyDispatchService(
      contactService: contactService,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 3.0, 'longitude': 4.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.none),
      logService: logService,
      notificationService: notificationService,
      sender: (n, m) async {},
    );
    when(
      () => notificationService.showDispatchFailureNotification(),
    ).thenAnswer((_) async {});
    await service.dispatch('data');
    expect(logService.logs.single.success, isFalse);
    verify(
      () => notificationService.showDispatchFailureNotification(),
    ).called(1);
  });
}