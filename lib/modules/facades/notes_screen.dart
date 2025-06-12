// lib/modules/facades/notes_screen.dart
import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.config);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aquí podrás escribir tus notas'),
            const SizedBox(height: 20),
            TextField(
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe tus notas aquí...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
