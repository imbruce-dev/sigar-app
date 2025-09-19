import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/startup_page.dart'; // Importation de la page de démarrage
import 'pages/login_page.dart'; // Importation de la page de login
import 'pages/connexion_page.dart'; // Importation de la page de connexion
import 'pages/inscription_page.dart'; // Importation de la page d'inscription
import 'pages/bottom_nav_bar.dart'; // Importation de la page de la bottom nav bar
import 'pages/vehicule_ajout/vehicule_ajout_page.dart'; // Importation de la page ajout de véhicule
import 'pages/verification_ponctuelle_page.dart'; // Importation de la page vérification ponctuelle
import 'pages/pv_ponctuelle_page.dart'; // Importation de la page PV ponctuelle

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupFirebaseMessaging(); // Appel de la configuration Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configuration des notifications locales
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const SigarApp());
}

class SigarApp extends StatefulWidget {
  const SigarApp({super.key});

  static _SigarAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SigarAppState>();

  @override
  _SigarAppState createState() => _SigarAppState();
}

class _SigarAppState extends State<SigarApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartupPage(), // Set StartupPage as the initial page
      routes: {
        '/login': (context) => const SigarLogin(), // Route for the login page
        '/connexion': (context) => const ConnexionPage(), // Route for the connection page
        '/inscription': (context) => const InscriptionPage(), // Route for the signup page
        '/home': (context) => const BottomNavBar(), // Route for the bottom navigation bar
        '/vehicule_ajout': (context) => const VehiculeAjoutPage(), // Route for the vehicle addition page
        '/verification_ponctuelle': (context) => const VerificationPonctuellePage(), // Route for the verification page
        '/pv_ponctuelle': (context) => PvPonctuellePage(vehicleId: ''), // Route for the PV listing page (added a placeholder for vehicleId)
      },
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: _themeMode, // Current theme mode
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
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF013781), // Blue background color
      body: Center(
        child: Image.asset(
          'lib/assets/images/logo-whitesigar.png', // Path to the white SIGAR logo
          width: 150, // Set desired width for the logo
          height: 150, // Set desired height for the logo
        ),
      ),
    );
  }
}

void setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Demander la permission pour les notifications (iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Obtenir le token FCM
  String? token = await messaging.getToken();
  if (token != null) {
    // Enregistrer le token FCM dans SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcmToken', token);
    print('FCM Token generated and stored: $token');
  }

  // Gérer les notifications en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message data: ${message.data}');
    if (message.notification != null) {
      _showNotification(message);
    }
  });

  // Gérer les notifications lorsque l'application est ouverte via la notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
  });
}

void _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true, // Assurez-vous que l'alerte sonore est active.
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'Nouvelle notification',
    message.notification?.body ?? 'Vous avez une nouvelle notification',
    platformChannelSpecifics,
    payload: 'item x',
  );
}
