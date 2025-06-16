import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'modules/config/config_screen.dart';
import 'modules/facades/finance_screen.dart';
import 'shared/services/facade_service.dart';
import 'shared/services/shake_service.dart';
import 'shared/services/noise_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/recording_service.dart';
import 'shared/services/contact_service.dart';
import 'shared/services/config_service.dart';
import 'shared/services/emergency_dispatch_service.dart';

/// App principal: gestión de autenticación, detección de eventos y rutas
class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false, _servicesStarted = false, _requireContacts = false;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _facade = FacadeService();
  final _recording = RecordingService();
  final _contactService = ContactService();
  final _configService = ConfigService();

  late final NotificationService _notification;
  late final EmergencyDispatchService _dispatch;
  ShakeService? _shake;
  NoiseService? _noise;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _notification = NotificationService(_recording)..init();
    _dispatch = EmergencyDispatchService(sender: (_, __) async {})
      ..startConnectivityMonitor();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChange);
    FlutterBackgroundService().on('emergency').listen((_) => _showEmergency());
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkModeEnabled') ?? false;
    await _facade.loadSavedFacade();
    final cfg = await _configService.fetch();
    if (cfg?['recordingDuration'] is int)
      _recording.duration = Duration(seconds: cfg!['recordingDuration']);
    _checkSetup(prefs);
    setState(() {});
  }

  void _checkSetup(SharedPreferences prefs) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final contacts = await _contactService.getContacts();
    final pin = prefs.getString('configPin') ?? '';
    if (pin.isEmpty) {
      _requireContacts = contacts.isEmpty;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _navigatorKey.currentState?.pushReplacementNamed(
          AppRoutes.pinSetup,
        ),
      );
      return;
    }

    if (contacts.isEmpty) {
      _requireContacts = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) =>
            _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.config),
      );
    }
  }

  void _onAuthChange(User? user) {
    user != null ? _startServices() : _stopServices();
  }

  void _startServices() {
    if (_servicesStarted) return;
    _servicesStarted = true;
    _shake = ShakeService(onTrigger: _showEmergency)..start();
    _noise = NoiseService(onTrigger: _showEmergency)..start();
  }

  void _stopServices() {
    if (!_servicesStarted) return;
    _servicesStarted = false;
    _shake?.dispose();
    _noise?.dispose();
  }

  void _showEmergency() =>
      _notification.showEmergencyNotification(onTimeout: _startRecording);

  void _startRecording() => _recording.recordFor30Seconds(
    onInsufficientStorage: _notification.showLowStorageWarning,
  );

  void _onContactsSaved() {
    if (!_requireContacts) return;
    _requireContacts = false;
    _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _stopServices();
    _dispatch.dispose();
    _notification.cancelEmergency();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => MaterialApp(
    navigatorKey: _navigatorKey,
    title: 'App Camuflada',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
    initialRoute: widget.initialRoute,
    routes: {
      ...AppRoutes.routes,
      AppRoutes.home: (_) => FinanceScreen(noiseService: _noise!),
      AppRoutes.config: (_) => ConfigScreen(
        isDarkModeEnabled: _isDarkMode,
        onThemeChanged: (d) => setState(() => _isDarkMode = d),
        onContactsSaved: _onContactsSaved,
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
