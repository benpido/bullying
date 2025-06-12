import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/finance_summary_card.dart';
import '../config/config_screen.dart'; // importar para poder usar direto

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Exemplo: você precisa adaptar esses valores conforme seu app real
  final bool isDarkModeEnabled = false;
  void onThemeChanged(bool value) {
    // Implementar alteração real do tema
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ConfigScreen(
                        isDarkModeEnabled: isDarkModeEnabled,
                        onThemeChanged: onThemeChanged,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const FinanceSummaryCard(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.warning),
            label: const Text('Emergencia'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.emergency);
            },
          ),
        ],
      ),
    );
  }
}
