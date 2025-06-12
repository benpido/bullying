import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class FacadeSelector extends StatelessWidget {
  const FacadeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccionar Fachada:'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            _buildFacadeButton(context, 'Finanzas', AppRoutes.home),
            _buildFacadeButton(context, 'Calendario', AppRoutes.calendar),
            _buildFacadeButton(context, 'Calculadora', AppRoutes.calculator),
            _buildFacadeButton(context, 'Notas', AppRoutes.notes),
          ],
        ),
      ],
    );
  }

  Widget _buildFacadeButton(BuildContext context, String label, String route) {
    return ElevatedButton(
      onPressed: () {
        // Actualizamos la fachada seleccionada
        AppRoutes.currentFacade = route;
        Navigator.pushNamed(context, route);
      },
      child: Text(label),
    );
  }
}
