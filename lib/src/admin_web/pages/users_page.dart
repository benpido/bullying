import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  Future<void> _createUser() async {
    try {
      final adminId = FirebaseAuth.instance.currentUser!.uid;
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminId)
          .get();
      final adminData = adminDoc.data();
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': _email.text,
        'adminId': adminId,
        'adminName': adminData?['name'],
        'adminPhone': adminData?['phone'],
      });
      _email.clear();
      _password.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _delete(String id) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _createUser, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (c, i) {
                  final d = docs[i];
                  return ListTile(
                    title: Text(d['email'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(d.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}