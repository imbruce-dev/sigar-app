import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vehicle_service.dart'; // ✅ Service API véhicule
import 'package:sigar/pages/vehicule_ajout/components/dialogs.dart'; // ✅ Dialogs utilisés proprement

class StepClaimOwnership extends StatefulWidget {
  final String registrationNumber;
  final File? capturedImage;
  final Function(File image) onImageCaptured;

  const StepClaimOwnership({
    super.key,
    required this.registrationNumber,
    required this.capturedImage,
    required this.onImageCaptured,
  });

  @override
  State<StepClaimOwnership> createState() => _StepClaimOwnershipState();
}

class _StepClaimOwnershipState extends State<StepClaimOwnership> {
  final ImagePicker _picker = ImagePicker();
  final VehicleService _vehicleService = VehicleService();
  bool _isLoading = false;

  Future<void> _captureImage() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final file = File(image.path);
        widget.onImageCaptured(file);
      }
    } else {
      await showSimpleMessageDialog(
        context: context,
        message: 'Permission caméra refusée.',
      );
    }
  }

  Future<void> _claimOwnership() async {
    if (widget.capturedImage == null) {
      await showSimpleMessageDialog(
        context: context,
        message: 'Veuillez prendre une photo du document de propriété.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) {
        await showSimpleMessageDialog(
          context: context,
          message: 'Token non trouvé. Veuillez vous reconnecter.',
        );
        return;
      }

      bool success = await _vehicleService.claimVehicleOwnership(
        widget.registrationNumber,
        token,
      );

      if (success) {
        await showSimpleMessageDialog(
          context: context,
          message: 'Propriété du véhicule réclamée avec succès.',
          isSuccess: true,
        );
      } else {
        await showSimpleMessageDialog(
          context: context,
          message: 'Erreur lors de la réclamation de propriété.',
        );
      }
    } catch (e) {
      await showSimpleMessageDialog(
        context: context,
        message: 'Erreur : ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Veuillez prendre une photo d'un document prouvant la propriété du véhicule (carte grise).",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _captureImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Ouvrir la caméra"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        if (widget.capturedImage != null)
          Image.file(
            widget.capturedImage!,
            height: 200,
          ),
        const SizedBox(height: 30),
        Center(
          child: Lottie.asset('lib/assets/animations/f7lPpYl4S7.json', height: 200),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _claimOwnership,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirmer"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
