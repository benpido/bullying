import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/contact_model.dart';

class ContactService {
  static const String _contactsKey = 'contacts';

  // Salvar contatos no SharedPreferences
  Future<void> setContacts(List<ContactModel> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> contactsJson =
        contacts
            .map(
              (contact) => json.encode({
                'name': contact.name,
                'phoneNumber': contact.phoneNumber,
              }),
            )
            .toList();
    await prefs.setStringList(_contactsKey, contactsJson);
  }

  // Carregar contatos do SharedPreferences
  Future<List<ContactModel>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? contactsJson = prefs.getStringList(_contactsKey);
    if (contactsJson != null) {
      return contactsJson.map((contact) {
        final Map<String, dynamic> contactMap = json.decode(contact);
        return ContactModel(
          name: contactMap['name'],
          phoneNumber: contactMap['phoneNumber'],
        );
      }).toList();
    }
    return []; // Se não houver contatos, retorna uma lista vazia
  }
}
