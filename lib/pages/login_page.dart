import 'package:flutter/material.dart';

class SigarLogin extends StatefulWidget {
  const SigarLogin({super.key});

  @override
  _SigarLoginState createState() => _SigarLoginState();
}

class _SigarLoginState extends State<SigarLogin> {
  int currentStep = 0;

  List<Map<String, String>> steps = [
    {
      "image": "lib/assets/images/step1.png",
      "title": "Identifiez-vous",
      "description":
          "Inscrivez-vous et profitez de tous les avantages et fonctionnalités qu'offre notre application.",
    },
    {
      "image": "lib/assets/images/step2.png",
      "title": "Ajoutez votre Immatriculation",
      "description": "Saisissez les informations d'immatriculations de vos véhicules et parcourez votre compte.",
    },
    {
      "image": "lib/assets/images/step3.png",
      "title": "Gérez vos contraventions en toute simplicité",
      "description": "Consultez et gérez vos contraventions directement depuis votre application SIGAR.",
    },
  ];

  // Fonction pour aller à l'étape suivante
  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        // Si l'utilisateur est sur la dernière étape, on le redirige vers la page de connexion
        Navigator.pushNamed(context, '/connexion');
      }
    });
  }

  // Fonction pour revenir à l'étape précédente
  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              // Swipe vers la gauche (passer à l'étape suivante)
              nextStep();
            } else if (details.primaryVelocity! > 0) {
              // Swipe vers la droite (revenir à l'étape précédente)
              previousStep();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo agrandi
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'lib/assets/images/logobluesigar.png',
                  height: 120, // Agrandir le logo sans toucher à la position
                ),
              ),
              // Step Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildStepIndicator(0),
                    buildStepIndicator(1),
                    buildStepIndicator(2),
                  ],
                ),
              ),
              // Step Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step Image
                    Image.asset(
                      steps[currentStep]["image"]!,
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      steps[currentStep]["title"]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF013781), // Blue color for title
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        steps[currentStep]["description"]!,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Next Button
              GestureDetector(
                onTap: nextStep,
                child: Container(
                  color: const Color(0xFF4266B5), // Blue button color
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentStep == 2 ? "Identifiez-vous" : "Suivant",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the step indicator
  Widget buildStepIndicator(int step) {
    bool isActive = step == currentStep;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6), // Augmenter la longueur
      width: isActive ? 40 : 20, // Step actif plus long
      height: 6, // Augmenter légèrement la hauteur
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF013781) : Colors.grey[300], // Active step color
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
