import 'package:flutter/material.dart';

class EmergencyConfirmedScreen extends StatelessWidget {
  const EmergencyConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark; // Verifica o modo escuro

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 120,
            ),
            const SizedBox(height: 40),
            Text(
              '¡Emergencia Confirmada!',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.greenAccent : Colors.green,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'La emergencia se activó con éxito.\n\nNuestro equipo está listo para atender.',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retorna para a tela anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 15,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
