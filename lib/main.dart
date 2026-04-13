import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'pages/login_page.dart';
import 'pages/connexion_page.dart';
import 'pages/inscription_page.dart';
import 'pages/bottom_nav_bar.dart';
import 'pages/vehicule_ajout/vehicule_ajout_page.dart';
import 'pages/verification_ponctuelle_page.dart';
import 'pages/pv_ponctuelle_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _showNotification(message);
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, s) {
    debugPrint("❌ Firebase init error: $e");
    debugPrintStack(stackTrace: s);
    return; // ✅ on stoppe sinon l'app peut rester blanche
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _initLocalNotifications();
  setupFirebaseMessaging(); // pas await : évite de bloquer l'écran si APNS met du temps

  runApp(const SigarApp());
}

Future<void> _initLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

class SigarApp extends StatefulWidget {
  const SigarApp({super.key});

  static _SigarAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SigarAppState>();

  @override
  State<SigarApp> createState() => _SigarAppState();
}

class _SigarAppState extends State<SigarApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setThemeMode(ThemeMode themeMode) {
    setState(() => _themeMode = themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartupPage(),
      routes: {
        '/login': (context) => const SigarLogin(),
        '/connexion': (context) => const ConnexionPage(),
        '/inscription': (context) => const InscriptionPage(),
        '/home': (context) => const BottomNavBar(),
        '/vehicule_ajout': (context) => const VehiculeAjoutPage(),
        '/verification_ponctuelle': (context) =>
            const VerificationPonctuellePage(),
        '/pv_ponctuelle': (context) => PvPonctuellePage(vehicleId: ''),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
    );
  }
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF013781),
      body: Center(
        child: Image.asset(
          'lib/assets/images/logo-whitesigar.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}

Future<void> setupFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  final NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  try {
  if (Platform.isIOS) {
    // Attendre que le token APNS soit disponible (sinon crash firebase_messaging/apns-token-not-set)
    String? apnsToken;
    for (int i = 0; i < 10; i++) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) break;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    debugPrint(' APNS token: ${apnsToken ?? "null (not ready yet)"}');
  }

  final String? token = await messaging.getToken();

  if (token != null) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
    debugPrint('✅ FCM Token stored: $token');
  } else {
    debugPrint('⚠️ FCM Token is null');
  }
} catch (e) {
  debugPrint('❌ Error while getting FCM token: $e');
}


  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('📩 onMessage data: ${message.data}');
    if (message.notification != null) {
      await _showNotification(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📬 onMessageOpenedApp: ${message.messageId}');
  });
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'Nouvelle notification',
    message.notification?.body ?? 'Vous avez une nouvelle notification',
    details,
  );
}

