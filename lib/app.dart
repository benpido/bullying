import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'modules/config/config_screen.dart';
import 'shared/services/facade_service.dart';
import 'shared/services/shake_service.dart';
import 'shared/services/noise_service.dart';
import 'modules/home/home_screen.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/recording_service.dart';
import 'shared/services/contact_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkModeEnabled = false;
  final FacadeService _facadeService = FacadeService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late ShakeService _shakeService;
  late NoiseService _noiseService;
  late NotificationService _notificationService;
  final RecordingService _recordingService = RecordingService();
  final ContactService _contactService = ContactService();
  bool _requireContacts = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadFacade();
    _checkContacts();
    _notificationService = NotificationService(_recordingService);
    _notificationService.init();
    _shakeService = ShakeService(
      onTrigger: () => _notificationService.showEmergencyNotification(
        onTimeout: _startRecording,
      ),
    );
    _shakeService.start();
    _noiseService = NoiseService(
      onTrigger: () => _notificationService.showEmergencyNotification(
        onTimeout: _startRecording,
      ),
    );
    _noiseService.start();
    FlutterBackgroundService().on('emergency').listen((event) {
      _notificationService.showEmergencyNotification(
        onTimeout: _startRecording,
      );
    });
    
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled = prefs.getBool('isDarkModeEnabled') ?? false;
    });
  }
    Future<void> _checkContacts() async {
    final contacts = await _contactService.getContacts();
    if (contacts.isEmpty) {
      _requireContacts = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.config);
      });
    }
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

  void _startRecording() {
    _recordingService.recordFor30Seconds();
  }

  void _onContactsSaved() {
    if (_requireContacts) {
      _requireContacts = false;
      _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _shakeService.dispose();
    _noiseService.dispose();
    _notificationService.cancelEmergency();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'App Camuflada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: () {
        final routes = Map<String, WidgetBuilder>.from(AppRoutes.routes);
        routes[AppRoutes.home] = (_) => HomeScreen(noiseService: _noiseService);
        routes[AppRoutes.config] = (context) => ConfigScreen(
              isDarkModeEnabled: _isDarkModeEnabled,
          onThemeChanged: updateTheme,
          onContactsSaved: _onContactsSaved,
        );
        return routes;
      }(),
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
