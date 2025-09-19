import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_page.dart';
import '../utils/notification_utils.dart'; // Import the utility file

class SigarHeader extends StatefulWidget {
  const SigarHeader({Key? key}) : super(key: key);

  @override
  _SigarHeaderState createState() => _SigarHeaderState();
}

class _SigarHeaderState extends State<SigarHeader> {
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
  }

  Future<void> checkUnreadNotifications() async {
    await updateUnreadNotificationsStatus(); // Call the global method to update the status
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasUnreadNotifications = prefs.getBool('hasUnreadNotifications') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // SIGAR Logo
          Image.asset(
            'lib/assets/images/logobluesigar.png',
            height: 120,
          ),
          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'lib/assets/svg/mage--notification-bell-pending.svg',
                  height: 25,
                  width: 25,
                  color: const Color(0xFF013781),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  ).then((_) => checkUnreadNotifications());
                },
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}