import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'modules/config/config_screen.dart';
import 'shared/services/facade_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkModeEnabled = false;
  final FacadeService _facadeService = FacadeService();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadFacade();
    
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled = prefs.getBool('isDarkModeEnabled') ?? false;
    });
  }
    Future<void> _loadFacade() async {
    await _facadeService.loadSavedFacade();
    setState(() {});
  }


  void updateTheme(bool isDark) {
    setState(() {
      _isDarkModeEnabled = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Camuflada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        ...AppRoutes.routes,
        AppRoutes.config:
            (context) => ConfigScreen(
              isDarkModeEnabled: _isDarkModeEnabled,
              onThemeChanged: updateTheme,
            ),
      },
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
