import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sigar/pages/vehicule_ajout/components/country_picker.dart'; // 🏁

class StepRegistration extends StatelessWidget {
  final TextEditingController registrationController;
  final bool isRegistrationValid;
  final String selectedCountry;
  final ValueChanged<String> onCountrySelected;
  final ValueChanged<String> onRegistrationChanged;

  const StepRegistration({
    super.key,
    required this.registrationController,
    required this.isRegistrationValid,
    required this.selectedCountry,
    required this.onCountrySelected,
    required this.onRegistrationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pays d'immatriculation", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        
        // ✅ Utilisation propre de CountryPicker
        CountryPicker(
          selectedCountry: selectedCountry,
          onCountrySelected: onCountrySelected,
        ),

        const SizedBox(height: 20),
        const Text("Numéro d'immatriculation", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: registrationController,
          decoration: InputDecoration(
            hintText: "Ex: AB123CD",
            border: const OutlineInputBorder(),
            errorText: isRegistrationValid ? null : "Ce champ est obligatoire",
          ),
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (text) {
            onRegistrationChanged(text.toUpperCase());
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: Lottie.asset(
            'lib/assets/animations/yf7F5yWBlV.json',
            height: 200,
          ),
        ),
      ],
    );
  }
}
