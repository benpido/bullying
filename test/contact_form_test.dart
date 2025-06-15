import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bullying/modules/config/widgets/contact_form.dart';
import 'package:bullying/shared/services/contact_service.dart';
import 'package:bullying/shared/models/contact_model.dart';

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

    expect(find.text('Se requieren dos contactos válidos'), findsOneWidget);
    verifyNever(() => service.setContacts(any()));
  });
  testWidgets('saving with two valid phones stores contacts', (tester) async {
    final service = MockContactService();
    when(() => service.getContacts()).thenAnswer((_) async => []);
    when(() => service.setContacts(any())).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ContactForm(contactService: service)),
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Alice');
    await tester.enterText(fields.at(1), '+12345678');
    await tester.enterText(fields.at(2), 'Bob');
    await tester.enterText(fields.at(3), '+87654321');

    await tester.tap(find.text('Guardar Contactos'));
    await tester.pump();

    final contactsArg =
        verify(() => service.setContacts(captureAny())).captured.single as List<ContactModel>;
    expect(contactsArg.length, 2);
    expect(contactsArg.first.name, 'Alice');
    expect(contactsArg.first.phoneNumber, '+12345678');
    expect(contactsArg[1].name, 'Bob');
    expect(contactsArg[1].phoneNumber, '+87654321');
    expect(find.text('Contactos guardados'), findsOneWidget);
  });
}