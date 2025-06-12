import 'package:flutter/material.dart';
import '../../../shared/models/contact_model.dart';
import '../../../shared/services/contact_service.dart';

class ContactForm extends StatefulWidget {
  final ContactService contactService;

  const ContactForm({super.key, required this.contactService});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _nameController1 = TextEditingController();
  final _phoneController1 = TextEditingController();
  final _nameController2 = TextEditingController();
  final _phoneController2 = TextEditingController();

  @override
  void dispose() {
    _nameController1.dispose();
    _phoneController1.dispose();
    _nameController2.dispose();
    _phoneController2.dispose();
    super.dispose();
  }

  // Salvar os contatos no SharedPreferences
  void _saveContacts() async {
    final contact1 = ContactModel(
      name: _nameController1.text,
      phoneNumber: _phoneController1.text,
    );

    final contact2 = ContactModel(
      name: _nameController2.text,
      phoneNumber: _phoneController2.text,
    );

    await widget.contactService.setContacts([contact1, contact2]);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contactos guardados')));
  }

  // Carregar os contatos salvos
  Future<void> _loadContacts() async {
    final contacts = await widget.contactService.getContacts();
    if (contacts.isNotEmpty) {
      _nameController1.text = contacts[0].name;
      _phoneController1.text = contacts[0].phoneNumber;
      if (contacts.length > 1) {
        _nameController2.text = contacts[1].name;
        _phoneController2.text = contacts[1].phoneNumber;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Carregar os contatos quando o formulário for exibido
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Contacto de Emergencia 1'),
        TextField(
          controller: _nameController1,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        TextField(
          controller: _phoneController1,
          decoration: const InputDecoration(labelText: 'Teléfono'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        const Text('Contacto de Emergencia 2'),
        TextField(
          controller: _nameController2,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        TextField(
          controller: _phoneController2,
          decoration: const InputDecoration(labelText: 'Teléfono'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveContacts,
          child: const Text('Guardar Contactos'),
        ),
      ],
    );
  }
}
