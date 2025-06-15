import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/contact_service.dart';
import 'widgets/contact_form.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/services/facade_service.dart';

class ConfigScreen extends StatefulWidget {
  final bool isDarkModeEnabled;
  final Function(bool) onThemeChanged;
  final VoidCallback? onContactsSaved;

  const ConfigScreen({
    super.key,
    required this.isDarkModeEnabled,
    required this.onThemeChanged,
    this.onContactsSaved,
  });

  @override
  ConfigScreenState createState() => ConfigScreenState();
}

class ConfigScreenState extends State<ConfigScreen> {
  late bool _isDarkModeEnabled;
  final ContactService contactService = ContactService();
  final FacadeService facadeService = FacadeService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDarkModeEnabled = widget.isDarkModeEnabled;
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkModeEnabled', value);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
    });
    _saveThemePreference(value);
    widget.onThemeChanged(value); // Atualiza o tema no MyApp
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _phoneController.text = prefs.getString('userPhoneNumber') ?? '';
  }

  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userPhoneNumber', _phoneController.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Datos guardados')));
    }
  }


  Widget _buildFacadeCarousel() {
    final facades = [
      {
        'label': 'Fianzas',
        'route': AppRoutes.home,
        'icon': Icons.account_balance_wallet,
      },
      {
        'label': 'Calendario',
        'route': AppRoutes.calendar,
        'icon': Icons.calendar_month,
      },
      {
        'label': 'Calculadora',
        'route': AppRoutes.calculator,
        'icon': Icons.calculate,
      },
      {'label': 'Notas', 'route': AppRoutes.notes, 'icon': Icons.note_alt},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: facades.length,
        itemBuilder: (context, index) {
          final facade = facades[index];
          return GestureDetector(
            onTap: () async {
              await facadeService.setFacade(facade['route'] as String);
              Navigator.pushReplacementNamed(
                context,
                facade['route'] as String,
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    facade['icon'] as IconData,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    facade['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Configuraciones de Emergencia')),
      body: SingleChildScrollView(
        // Para evitar overflow em telas menores
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modo Oscuro', style: TextStyle(fontSize: 16)),
            Switch(value: _isDarkModeEnabled, onChanged: _toggleTheme),
            const SizedBox(height: 20),

            const Text('Seleccionar Fachada:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            _buildFacadeCarousel(),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _phoneController,
              decoration:
                  const InputDecoration(labelText: 'Teléfono del dispositivo'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveUserInfo,
              child: const Text('Guardar Datos'),
            ),
            const SizedBox(height: 20),

            ContactForm(
              contactService: contactService,
              onContactsSaved: widget.onContactsSaved,
            ),
          ],
        ),
      ),
    );
  }
}
