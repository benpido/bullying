import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bullying/core/routes/app_routes.dart';
import 'package:bullying/modules/auth/lock_screen.dart';
import 'package:bullying/modules/auth/widgets/lock_input.dart';
import 'package:bullying/modules/config/config_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('failing unlock keeps screen blocked', (tester) async {
    SharedPreferences.setMockInitialValues({'configPin': '1234'});
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const LockScreen(nextRoute: AppRoutes.config),
        AppRoutes.config: (_) => ConfigScreen(
              isDarkModeEnabled: false,
              onThemeChanged: _noop,
            ),
      },
    ));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu contraseña para acceder'), findsOneWidget);

    Future<void> tapDigit(String d) async {
      await tester.tap(find.text(d).first);
      await tester.pump();
    }

    await tapDigit('1');
    await tapDigit('2');
    await tapDigit('3');
    await tapDigit('5');

    final grid = find.byType(GridView);
    await tester.drag(grid, const Offset(0, -500));
    await tester.pumpAndSettle();

    final checkButton = find.widgetWithIcon(ElevatedButton, Icons.check);
    await tester.tap(checkButton);
    await tester.pump();

    expect(find.text('Contraseña incorrecta'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Configuraciones de Emergencia'), findsNothing);
    expect(find.text('Ingresa tu contraseña para acceder'), findsOneWidget);
  });
}

void _noop(bool _) {}