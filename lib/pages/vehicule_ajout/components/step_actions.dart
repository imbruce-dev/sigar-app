import 'package:flutter/material.dart';
import 'package:sigar/pages/vehicule_ajout/components/dialogs.dart'; // ✅ Dialogs
import '../services/vehicle_service.dart'; // ✅ API call

class StepActions extends StatelessWidget {
  final int currentStep;
  final bool isVehicleExists;
  final VoidCallback onSkipStep;
  final Future<void> Function() onAddVehicle;
  final Future<void> Function() onClaimOwnership;
  final VoidCallback onNextStep;

  const StepActions({
    super.key,
    required this.currentStep,
    required this.isVehicleExists,
    required this.onSkipStep,
    required this.onAddVehicle,
    required this.onClaimOwnership,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentStep == 1 && !isVehicleExists)
          ElevatedButton(
            onPressed: onSkipStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              foregroundColor: Colors.white,
            ),
            child: const Text("Passer cette étape"),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (currentStep == 2) {
              if (!isVehicleExists) {
                await onAddVehicle(); // ➔ Appelle addVehicle()
              } else {
                onNextStep(); // ➔ Passe à la step de claim ownership
              }
            } else if (currentStep == 4) {
              await onClaimOwnership(); // ➔ Appelle claimOwnership()
            } else {
              onNextStep(); // ➔ Next étape normale
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: Colors.white,
          ),
          child: Text(currentStep == 4 ? "Confirmer" : "Étape suivante"),
        ),
      ],
    );
  }
}
