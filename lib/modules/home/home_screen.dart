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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.config),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FinanceSummaryCard(),
              const SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _MetricItem(label: 'Ingresos', value: '$ 12.345'),
                      _MetricItem(label: 'Gastos', value: '$ 7.890'),
                      _MetricItem(label: 'Balance', value: '$ 4.455'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Categorías',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _CategoryChip(label: 'Ahorro', icon: Icons.savings),
                  _CategoryChip(label: 'Comida', icon: Icons.fastfood),
                  _CategoryChip(label: 'Transporte', icon: Icons.directions_car),
                  _CategoryChip(label: 'Ocio', icon: Icons.movie),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '📈 Gráfico de Tendencia\n(implementación futura)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.warning),
                label: const Text('Emergencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pushNamed(
                    context, AppRoutes.emergency),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
    );
  }
}