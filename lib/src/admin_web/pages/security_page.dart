import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _controller = TextEditingController();

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('security')
        .get();
    if (doc.exists) {
      _controller.text = doc.data()!['password'] ?? '';
    }
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance.collection('config').doc('security').set({
      'password': _controller.text,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Updated')));
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
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Security password'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}