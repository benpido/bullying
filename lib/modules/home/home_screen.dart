import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/finance_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.config);
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
