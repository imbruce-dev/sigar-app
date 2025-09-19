import 'package:flutter/material.dart';
import 'package:sigar/pages/assistance_page.dart'; // Import AssistancePage

/// 🔹 Popup pour demander accès partagé ou réclamer propriété
Future<void> showSharedVehicleDialog({
  required BuildContext context,
  required VoidCallback onRequestShare,
  required VoidCallback onClaimOwnership,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Véhicule déjà ajouté'),
        content: const Text(
          'Ce véhicule est déjà associé à un autre utilisateur.\n'
          'Voulez-vous demander un accès partagé à ce véhicule ou réclamer la propriété ?',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Demander un accès partagé'),
            onPressed: () {
              Navigator.of(context).pop();
              onRequestShare();
            },
          ),
          TextButton(
            child: const Text('Réclamer la propriété'),
            onPressed: () {
              Navigator.of(context).pop();
              onClaimOwnership();
            },
          ),
        ],
      );
    },
  );
}

/// 🔹 Popup pour entrer le code de vérification
Future<void> showVerificationCodeDialog({
  required BuildContext context,
  required TextEditingController verificationCodeController,
  required VoidCallback onConfirmCode,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Code de vérification'),
        content: TextField(
          controller: verificationCodeController,
          decoration: const InputDecoration(
            hintText: 'Entrez le code de vérification',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Valider'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmCode();
            },
          ),
        ],
      );
    },
  );
}

/// 🔹 Popup simple pour afficher un message de succès ou erreur
Future<void> showSimpleMessageDialog({
  required BuildContext context,
  required String message,
  bool isSuccess = false,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            },
          ),
        ],
      );
    },
  );
}

/// 🔹 Popup pour contacter directement la page Assistance après 3 échecs OCR
Future<void> showContactSupportDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Assistance requise'),
        content: const Text(
          "Nous n'avons pas pu valider votre immatriculation après plusieurs tentatives.\n\n"
          "Vous pouvez contacter notre service client pour une vérification manuelle.",
        ),
        actions: [
          TextButton(
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4266B5),
              foregroundColor: Colors.white,
            ),
            child: const Text('Contacter le support'),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le popup

              // 🔥 Redirection directe vers AssistancePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssistancePage()),
              );
            },
          ),
        ],
      );
    },
  );
}
