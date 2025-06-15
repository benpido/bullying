import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  Future<void> _load() async {
    final id = FirebaseAuth.instance.currentUser?.uid;
    if (id == null) return;
    final doc = await FirebaseFirestore.instance.collection('admins').doc(id).get();
    if (doc.exists) {
      _name.text = doc.data()!['name'] ?? '';
      _phone.text = doc.data()!['phone'] ?? '';
    }
  }

  Future<void> _save() async {
    final id = FirebaseAuth.instance.currentUser?.uid;
    if (id == null) return;
    await FirebaseFirestore.instance.collection('admins').doc(id).set({
      'name': _name.text,
      'phone': _phone.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}