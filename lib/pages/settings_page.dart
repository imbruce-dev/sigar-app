import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sigar/main.dart';
import './profil_page.dart'; // Import de ProfilPage
import './methode_de_paiement_page.dart'; // Import de PaymentMethodsPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white), // Titre en blanc
        ),
        backgroundColor: const Color(0xFF013781), // Couleur bleue primaire de l'app SIGAR
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section Compte
          const SectionTitle(title: 'Compte'),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/iconamoon--profile.svg', // Chemin SVG correct
            'Profil',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilPage(), // Navigation vers ProfilPage
                ),
              );
            },
          ),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/hugeicons--credit-card.svg', // Chemin SVG correct
            'Paiement',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodsPage(), // Navigation vers PaymentMethodsPage
                ),
              );
            },
          ),

          // Section Préférences de l'application
          const SectionTitle(title: 'Préférences de l\'application'),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/material-symbols-light--language.svg', // Chemin SVG correct
            'Langue',
            () {
              print("Navigating to Language Settings");
            },
          ),
          _buildDarkModeSwitch(context), // Dark Mode Switch

          // Section À propos de l'application
          const SectionTitle(title: 'À propos de l\'application'),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/solar--documents-line-duotone.svg', // Chemin SVG correct
            'Conditions générales',
            () {
              print("Navigating to Legal Info");
            },
          ),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/mdi--security.svg', // Chemin SVG correct
            'Politique de confidentialité',
            () {
              print("Navigating to Privacy Policy");
            },
          ),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/fluent--share-28-regular.svg', // Chemin SVG correct
            'Partager l\'application',
            () {
              Share.share(
                'Salut! Je te conseille de télécharger l\'application SIGAR sur l\'Apple Store ou le Play Store : https://www.example.com',
                subject: 'Découvrez SIGAR!',
              );
            },
          ),

          // Logout
          const SizedBox(height: 16),
          _buildBoxedSettingItem(
            context,
            'lib/assets/svg/ci--log-out.svg', // Chemin SVG correct
            'Se déconnecter',
            () {
              print("User logged out");
            },
          ),
        ],
      ),
    );
  }

  // Fonction pour créer un élément de paramètres sous forme de boîte
  Widget _buildBoxedSettingItem(BuildContext context, String iconPath, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // Espace entre chaque boîte
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc pour chaque boîte
        borderRadius: BorderRadius.circular(10.0), // Coins légèrement arrondis
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Légère ombre
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // Décalage de l'ombre
          ),
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: 24.0, // Ajustement de la taille de l'icône
          color: const Color(0xFF013781), // Couleur bleue primaire de l'app SIGAR
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }

  // Fonction pour créer l'option du mode jour/nuit
  Widget _buildDarkModeSwitch(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc pour la boîte du switch
        borderRadius: BorderRadius.circular(10.0), // Coins légèrement arrondis
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Légère ombre
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // Décalage de l'ombre
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.brightness_6, color: Color(0xFF013781)),
        title: const Text('Mode jour/nuit', style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            SigarApp.of(context)?.setThemeMode(
              value ? ThemeMode.dark : ThemeMode.light,
            );
          },
          activeColor: Colors.blue,
        ),
      ),
    );
  }
}

// Widget pour afficher le titre de chaque section
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
