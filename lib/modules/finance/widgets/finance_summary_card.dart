import 'package:flutter/material.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Saldo: \$0.00'),
      ),
    );
  }
}
