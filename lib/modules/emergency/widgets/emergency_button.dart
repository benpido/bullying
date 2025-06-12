import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.2),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      child: const Text('Emergencia'),
    );
  }
}
