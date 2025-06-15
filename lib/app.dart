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
import 'shared/services/emergency_dispatch_service.dart';
import 'shared/services/config_service.dart';

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

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
  final ConfigService _configService = ConfigService();
  late EmergencyDispatchService _dispatchService;
  bool _requireContacts = false;

  @override
  void initState() {
    super.initState();
    _dispatchService = EmergencyDispatchService(sender: (n, m) async {});
    _dispatchService.startConnectivityMonitor();
    _loadConfig();
    _loadThemePreference();
    _loadFacade();
    _checkSetup();
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
  Future<void> _checkSetup() async {
    final contacts = await _contactService.getContacts();
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('configPin');
    if (contacts.length < 2 || pin == null || pin.isEmpty) {
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

  Future<void> _loadConfig() async {
    final cfg = await _configService.fetch();
    final seconds = cfg?['recordingDuration'];
    if (seconds is int) {
      _recordingService.duration = Duration(seconds: seconds);
    }
  }

  void updateTheme(bool isDark) {
    setState(() {
      _isDarkModeEnabled = isDark;
    });
  }

  void _startRecording() {
    _recordingService.recordFor30Seconds(
      onInsufficientStorage: _notificationService.showLowStorageWarning,
    );
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
    _dispatchService.dispose();
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
      initialRoute: widget.initialRoute,
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
