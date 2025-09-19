import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import manquant

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    setupFirebaseForegroundHandler(); // Pour écouter les notifications en premier plan.
  }

  Future<void> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'http://16.171.22.200:5000/api/notifications/my-notifications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = json.decode(response.body);
          isLoading = false;
        });
        updateUnreadNotificationsStatus();
      } else {
        print('Failed to load notifications');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateUnreadNotificationsStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasUnread = notifications.any((notification) => !(notification['isRead'] ?? false));
    await prefs.setBool('hasUnreadNotifications', hasUnread);
  }

  Future<void> markAsRead(String notificationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            'http://16.171.22.200:5000/api/notifications/$notificationId/mark-as-read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = notifications.map((notification) {
            if (notification['_id'] == notificationId) {
              notification['isRead'] = true;
            }
            return notification;
          }).toList();
        });
        updateUnreadNotificationsStatus();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void setupFirebaseForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(
        message.notification?.title ?? 'Nouvelle notification',
        message.notification?.body ?? 'Vous avez une nouvelle notification',
      );
    });
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  String formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF013781),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return GestureDetector(
                  onTap: () {
                    if (notification['isRead'] != true) {
                      markAsRead(notification['_id']);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: (notification['isRead'] ?? false)
                          ? Colors.grey[300]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['type'] ?? 'Notification',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF013781),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification['message'] ?? 'Pas de message',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Reçue le: ${formatDate(notification['createdAt'] ?? DateTime.now().toString())}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
