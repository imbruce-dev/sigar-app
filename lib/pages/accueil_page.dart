import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_page.dart'; // Importing the notification page
import '../utils/notification_utils.dart'; // Import the utility file

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF), // Arrière-plan légèrement plus bleuâtre
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo et Icône de notification en haut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo SIGAR à gauche
                Image.asset(
                  'lib/assets/images/logobluesigar.png',
                  height: 120, // Taille du logo
                ),
                // Icône de notification à droite
                Stack(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'lib/assets/svg/mage--notification-bell-pending.svg', // Chemin de l'icône
                        height: 25,
                        width: 25,
                        color: const Color(0xFF013781), // Icône de couleur bleue
                      ),
                      onPressed: () {
                        // Navigate to the notification page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationPage(),
                          ),
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
            const SizedBox(height: 20),

            // Blue Box Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF013781), // Bleu pour la box
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Partie texte
                  const Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIGAR app',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Découvrez notre application pour gérer vos contraventions et trouver la tranquillité d’esprit.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'lib/assets/images/CIGAR_accueil.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // First Box: Add a Vehicle
            buildOptionBox(
              context,
              'Ajouter un véhicule',
              'Ajoutez une nouvelle immatriculation pour suivre vos contraventions.',
              'lib/assets/svg/mingcute--car-3-fill.svg', // SVG icon path
              onTap: () {
                Navigator.pushNamed(context, '/vehicule_ajout'); // Navigate to vehicle addition page
              },
            ),

            const SizedBox(height: 20),

            // Second Box: Check PV
            buildOptionBox(
              context,
              'Vérification ponctuelle',
              'Faites une vérification instantanée sur une immatriculation pour détecter d’éventuels PV.',
              'lib/assets/svg/mdi--car-search.svg', // SVG icon path
              onTap: () {
                Navigator.pushNamed(context, '/verification_ponctuelle'); // Navigate to verification page
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour construire les mini-boxes
  Widget buildOptionBox(
      BuildContext context, String title, String description, String svgPath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, // Action lors du clic sur la box
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE1ECF8), // Couleur bleue claire pour la mini-box
          borderRadius: BorderRadius.circular(12), // Coins arrondis
          border: Border.all(color: const Color(0xFF013781), width: 2), // Contour bleu foncé
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône en SVG avec couleur bleue
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1E8FF), // Couleur de fond pour l'icône
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                svgPath,
                width: 40,
                height: 40,
                color: const Color(0xFF013781), // Icône en bleu
              ),
            ),
            const SizedBox(width: 16),
            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF013781), // Texte bleu foncé
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}