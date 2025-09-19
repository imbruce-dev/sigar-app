import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'pv_ponctuelle_page.dart'; // Importation de la page PV ponctuelle
import 'payment_widget.dart'; // Importation du widget de paiement

class VerificationPonctuellePage extends StatefulWidget {
  const VerificationPonctuellePage({super.key});

  @override
  _VerificationPonctuellePageState createState() =>
      _VerificationPonctuellePageState();
}

class _VerificationPonctuellePageState
    extends State<VerificationPonctuellePage> {
  int _currentStep = 0;
  bool isRegistrationValid = true;
  TextEditingController registrationController = TextEditingController();
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  bool isPaymentSuccessful = false;

  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _capturedImage = File(image.path);
      });
    }
  }

  Future<void> getVehicleIdAndProceed() async {
    if (registrationController.text.isEmpty) {
      setState(() {
        isRegistrationValid = false;
      });
      return;
    }
    setState(() {
      isRegistrationValid = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      _showMessage('Erreur : Aucun token trouvé. Veuillez vous reconnecter.');
      return;
    }

    final registrationNumber = registrationController.text;

    try {
      final response = await http.get(
        Uri.parse('http://16.171.22.200:5000/api/vehicles/$registrationNumber'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final vehicleId = json.decode(response.body)['_id'];
        // Naviguer vers le widget de paiement
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWidget(
              onPaymentSuccess: () {
                // Une fois le paiement réussi, naviguer vers la page PV
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PvPonctuellePage(vehicleId: vehicleId),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        _showMessage(
            'Erreur lors de la vérification du véhicule. Impossible de récupérer l\'ID.');
      }
    } catch (e) {
      _showMessage('Erreur lors de la vérification du véhicule.');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification de véhicule"),
        backgroundColor: const Color(0xFF013781),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep == 1
            ? getVehicleIdAndProceed // Le bouton Continue fonctionne seulement pour le Step 2
            : null,
        onStepCancel: _currentStep > 0
            ? () {
                setState(() {
                  _currentStep--;
                });
              }
            : null,
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
          // Boutons affichés uniquement au Step 2
          return _currentStep == 1
              ? Row(
                  children: [
                    ElevatedButton(
                      onPressed: controls.onStepContinue,
                      child: const Text("Vérifier",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4266B5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: controls.onStepCancel,
                      child: const Text("Retour"),
                    ),
                  ],
                )
              : const SizedBox.shrink(); // Aucun bouton au Step 1
        },
        steps: [
          Step(
            title: Center(
              child: Text(
                "Vérification ponctuelle",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF013781),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Effectuez une vérification rapide pour voir les contraventions associées à un véhicule.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Lottie.asset(
                  'lib/assets/animations/ti9izU3A8T.json',
                  height: 150,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: registrationController,
                  decoration: InputDecoration(
                    hintText: "Numéro d'immatriculation (Ex: AB123CD)",
                    errorText: !isRegistrationValid
                        ? "Ce champ est obligatoire"
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (registrationController.text.isNotEmpty) {
                      setState(() {
                        isRegistrationValid = true;
                        _currentStep++;
                      });
                    } else {
                      setState(() {
                        isRegistrationValid = false;
                      });
                    }
                  },
                  child: const Text(
                    "Suivant",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4266B5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text(""),
            content: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: captureImage,
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.white), // Icône en blanc
                  label: const Text("Télécharger la preuve d'appartenance",
                      style: TextStyle(color: Colors.white)), // Texte en blanc
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4266B5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_capturedImage != null)
                  Image.file(
                    _capturedImage!,
                    height: 200,
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: getVehicleIdAndProceed,
                  child: const Text("Vérifier",
                      style: TextStyle(color: Colors.white)), // Texte en blanc
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4266B5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}