// lib/utils/notification_utils.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateUnreadNotificationsStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');

  if (token == null) {
    return;
  }

  try {
    final response = await http.get(
      Uri.parse('http://16.171.22.200:5000/api/notifications/my-notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> notifications = json.decode(response.body);
      bool hasUnread = notifications.any((notification) => !(notification['isRead'] ?? false));
      await prefs.setBool('hasUnreadNotifications', hasUnread);
    } else {
      print('Failed to load notifications');
    }
  } catch (e) {
    print('Error fetching notifications: $e');
  }
}