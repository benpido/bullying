import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullying/modules/config/widgets/contact_form.dart';
import 'package:bullying/shared/services/contact_service.dart';

class MockContactService extends Mock implements ContactService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saving invalid phone numbers is rejected', (tester) async {
    final service = MockContactService();
    when(() => service.getContacts()).thenAnswer((_) async => []);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ContactForm(contactService: service)),
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Alice');
    await tester.enterText(fields.at(1), '123');
    await tester.enterText(fields.at(2), 'Bob');
    await tester.enterText(fields.at(3), 'abc');

    await tester.tap(find.text('Guardar Contactos'));
    await tester.pump();

    expect(find.text('Número de teléfono inválido'), findsOneWidget);
    verifyNever(() => service.setContacts(any()));
  });
}