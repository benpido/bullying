import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:location/location.dart';
import 'package:bullying/modules/config/config_screen.dart';
import 'package:bullying/shared/services/emergency_dispatch_service.dart';
import 'package:bullying/shared/services/contact_service.dart';
import 'package:bullying/shared/models/contact_model.dart';
import 'test_helpers.dart';

class MockContactService extends Mock implements ContactService {}

void main() {
  final binding =
      TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;

  setUp(() {
    binding.window.physicalSizeTestValue = const Size(800, 1600);
    binding.window.devicePixelRatioTestValue = 1.0;
    FlutterError.onError = (details) {};
  });

  tearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
    FlutterError.onError = FlutterError.dumpErrorToConsole;
  });

  testWidgets('fields load and persist user data', (tester) async {
    SharedPreferences.setMockInitialValues({
      'userName': 'Alice',
      'userPhoneNumber': '111',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: ConfigScreen(isDarkModeEnabled: false, onThemeChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    tester.takeException();
    tester.takeException();

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, 'Alice');
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '111');

    await tester.enterText(fields.at(0), 'Bob');
    await tester.enterText(fields.at(1), '999');
    await tester.tap(find.text('Guardar Datos'));
    await tester.pump();
    tester.takeException();
    tester.takeException();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('userName'), 'Bob');
    expect(prefs.getString('userPhoneNumber'), '999');
  });

  testWidgets('dispatch uses saved user data', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: ConfigScreen(isDarkModeEnabled: false, onThemeChanged: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Carl');
    await tester.enterText(fields.at(1), '123');
    await tester.tap(find.text('Guardar Datos'));
    await tester.pump();

    final serviceContact = MockContactService();
    when(
      () => serviceContact.getContacts(),
    ).thenAnswer((_) async => [ContactModel(name: 'c', phoneNumber: '1')]);
    final storage = FakeStorage();
    final sent = <String>[];
    final service = EmergencyDispatchService(
      contactService: serviceContact,
      storage: storage,
      location: FakeLocation(
        LocationData.fromMap({'latitude': 1.0, 'longitude': 2.0}),
      ),
      connectivity: FakeConnectivity(ConnectivityResult.wifi),
      logService: FakeLogService(),
      sender: (n, m) async => sent.add(m),
    );
    await service.dispatch('audio');
    expect(sent.single, contains('Nombre: Carl'));
    expect(sent.single, contains('Teléfono: 123'));
  });
}