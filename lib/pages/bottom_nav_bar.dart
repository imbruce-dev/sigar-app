import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accueil_page.dart'; // Import AccueilPage
import 'mes_vehicules_page.dart'; // Import MesVehiculesPage
import 'assistance_page.dart'; // Import AssistancePage
import 'settings_page.dart'; // Import SettingsPage (updated)
import 'add_pv_page.dart'; // Import AddPVPage (for creating contraventions)

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Index for the selected item
  String userRole = 'user'; // Default to 'user'

  // List of pages (or widgets) corresponding to each Bottom Nav option
  final List<Widget> _userPages = [
    AccueilPage(), // Home
    MesVehiculesPage(), // My Vehicles
    AssistancePage(), // Support/Assistance
    SettingsPage(),   // Settings Page
  ];

  final List<Widget> _bossUserPages = [
    AccueilPage(), // Home
    MesVehiculesPage(), // My Vehicles
    AssistancePage(), // Support/Assistance
    AddPVPage(), // Create Contraventions Page (only for boss users)
    SettingsPage(),   // Settings Page
  ];

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Fetch the user's role when initializing the widget
  }

  Future<void> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? 'user'; // Retrieve role from SharedPreferences
    });
  }

  // Function to handle navigation taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = userRole == 'boss_user' ? _bossUserPages : _userPages;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          // If the current page is "Accueil", minimize the app instead of logging out
          return true; // This allows the app to close
        } else {
          // If another page is selected, navigate back to "Accueil"
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Prevent the default back action
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: pages[_selectedIndex], // Current page based on selected index
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Ensures labels are shown
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF013781), // Blue color for selected item
          unselectedItemColor: Colors.grey, // Gray color for unselected items
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true, // To show labels for unselected items
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          items: [
            // Home (Accueil)
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/assets/svg/hugeicons--home-01.svg',
                color: _selectedIndex == 0 ? const Color(0xFF013781) : Colors.grey,
              ),
              label: 'Accueil',
            ),
            // Mes Véhicules
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/assets/svg/mingcute--car-2-line.svg',
                color: _selectedIndex == 1 ? const Color(0xFF013781) : Colors.grey,
              ),
              label: 'Mes Véhicules',
            ),
            // Assistance
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/assets/svg/hugeicons--customer-support.svg',
                color: _selectedIndex == 2 ? const Color(0xFF013781) : Colors.grey,
              ),
              label: 'Assistance',
            ),
            // Create Contraventions (Boss User Only)
            if (userRole == 'boss_user')
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'lib/assets/svg/iconamoon--profile.svg',
                  color: _selectedIndex == 3 ? const Color(0xFF013781) : Colors.grey,
                ),
                label: 'Contraventions',
              ),
            // Paramètres (Settings)
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'lib/assets/svg/hugeicons--settings-01.svg',
                color: _selectedIndex == (userRole == 'boss_user' ? 4 : 3) ? const Color(0xFF013781) : Colors.grey,
              ),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}
