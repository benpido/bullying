import 'package:flutter/material.dart';
import '../../shared/index.dart';
import 'package:bullying/shared/models/contact_model.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _service = ContactService();
  final _name1 = TextEditingController();
  final _phone1 = TextEditingController();
  final _name2 = TextEditingController();
  final _phone2 = TextEditingController();

  Future<void> _load() async {
    final contacts = await _service.getContacts();
    if (contacts.isNotEmpty) {
      final c1 = contacts[0];
      _name1.text = c1.name;
      _phone1.text = c1.phoneNumber;
      if (contacts.length > 1) {
        final c2 = contacts[1];
        _name2.text = c2.name;
        _phone2.text = c2.phoneNumber;
      }
    }
  }

  Future<void> _save() async {
    final list = <ContactModel>[];
    if (_name1.text.isNotEmpty && _phone1.text.isNotEmpty) {
      list.add(ContactModel(name: _name1.text, phoneNumber: _phone1.text));
    }
    if (_name2.text.isNotEmpty && _phone2.text.isNotEmpty) {
      list.add(ContactModel(name: _name2.text, phoneNumber: _phone2.text));
    }
    await _service.setContacts(list);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contacts saved')));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _name1,
            decoration: const InputDecoration(labelText: 'Name 1'),
          ),
          TextField(
            controller: _phone1,
            decoration: const InputDecoration(labelText: 'Phone 1'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name2,
            decoration: const InputDecoration(labelText: 'Name 2'),
          ),
          TextField(
            controller: _phone2,
            decoration: const InputDecoration(labelText: 'Phone 2'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}