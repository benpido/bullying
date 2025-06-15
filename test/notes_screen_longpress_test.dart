import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bullying/modules/facades/notes_screen.dart';
import 'package:bullying/core/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('long press on title navigates to emergency', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.emergency: (_) => const Scaffold(body: Text('Emergency')),
        },
        home: const NotesScreen(),
      ),
    );

    expect(find.text('Emergency'), findsNothing);

    await tester.longPress(find.text('Notas'));
    await tester.pumpAndSettle();

    expect(find.text('Emergency'), findsOneWidget);
  });
}