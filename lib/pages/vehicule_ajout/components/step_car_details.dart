import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';

class StepCarDetails extends StatefulWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final List<String> brands;
  final List<String> models;
  final List<String> years;
  final void Function(String brand) onBrandSelected;
  final void Function(String model) onModelSelected;
  final void Function(String year) onYearSelected;

  const StepCarDetails({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.brands,
    required this.models,
    required this.years,
    required this.onBrandSelected,
    required this.onModelSelected,
    required this.onYearSelected,
  });

  @override
  State<StepCarDetails> createState() => _StepCarDetailsState();
}

class _StepCarDetailsState extends State<StepCarDetails> {
  final VehicleService _vehicleService = VehicleService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Personnalisez votre expérience", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 20),

        // 🔹 Dropdown for brand selection
        DropdownButtonFormField<String>(
          value: widget.brandController.text.isNotEmpty ? widget.brandController.text : null,
          items: widget.brands.map((brand) {
            return DropdownMenuItem(
              value: brand,
              child: Text(brand),
            );
          }).toList(),
          hint: const Text('Sélectionner la marque'),
          onChanged: (newValue) async {
            if (newValue != null) {
              widget.onBrandSelected(newValue);

              // Lorsque la marque change -> fetch les modèles associés
              final models = await _vehicleService.fetchModels(newValue);
              setState(() {
                widget.models.clear();
                widget.models.addAll(models);
              });
            }
          },
        ),
        const SizedBox(height: 30),

        // 🔹 Dropdown for model selection
        DropdownButtonFormField<String>(
          value: widget.modelController.text.isNotEmpty ? widget.modelController.text : null,
          items: widget.models.map((model) {
            return DropdownMenuItem(
              value: model,
              child: Text(model),
            );
          }).toList(),
          hint: const Text('Sélectionner le modèle'),
          onChanged: (newValue) {
            if (newValue != null) {
              widget.onModelSelected(newValue);
            }
          },
        ),
        const SizedBox(height: 30),

        // 🔹 Dropdown for year selection
        DropdownButtonFormField<String>(
          value: widget.yearController.text.isNotEmpty ? widget.yearController.text : null,
          items: widget.years.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year),
            );
          }).toList(),
          hint: const Text('Sélectionner l\'année'),
          onChanged: (newValue) {
            if (newValue != null) {
              widget.onYearSelected(newValue);
            }
          },
        ),
      ],
    );
  }
}
