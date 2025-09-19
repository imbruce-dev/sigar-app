import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigar/pages/vehicule_ajout/components/country_picker.dart';
import 'package:sigar/pages/vehicule_ajout/components/dialogs.dart';
import 'package:sigar/pages/vehicule_ajout/components/step_actions.dart';
import 'package:sigar/pages/vehicule_ajout/components/step_car_details.dart';
import 'package:sigar/pages/vehicule_ajout/components/step_claim_ownership.dart';
import 'package:sigar/pages/vehicule_ajout/components/step_document_upload.dart';
import 'package:sigar/pages/vehicule_ajout/components/step_registration.dart';
import 'package:sigar/pages/vehicule_ajout/services/vehicle_service.dart';

class VehiculeAjoutPage extends StatefulWidget {
  const VehiculeAjoutPage({super.key});

  @override
  State<VehiculeAjoutPage> createState() => _VehiculeAjoutPageState();
}

class _VehiculeAjoutPageState extends State<VehiculeAjoutPage> {
  final VehicleService _vehicleService = VehicleService();

  int _currentStep = 0;
  bool isVehicleExists = false;
  int ocrFailureCount = 0; // 🆕 Compteur d'échecs OCR


  String selectedCountry = 'France';
  File? capturedImage;

  final TextEditingController registrationController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();

  List<String> brands = [];
  List<String> models = [];
  List<String> years = [];

  @override
  void initState() {
    super.initState();
    fetchBrands();
    fetchYears();
  }

  Future<void> fetchBrands() async {
    final fetchedBrands = await _vehicleService.fetchBrands();
    setState(() {
      brands = fetchedBrands;
    });
  }

  Future<void> fetchModels(String brand) async {
    final fetchedModels = await _vehicleService.fetchModels(brand);
    setState(() {
      models = fetchedModels;
    });
  }

  Future<void> fetchYears() async {
    final currentYear = DateTime.now().year;
    setState(() {
      years = List.generate(30, (index) => (currentYear - index).toString());
    });
  }

  Future<void> captureImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        capturedImage = File(image.path);
      });
    }
  }

  Future<void> _checkVehicleExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final exists = await _vehicleService.checkVehicleExists(registrationController.text, token);
    if (exists) {
      setState(() => isVehicleExists = true);
      await showSharedVehicleDialog(
        context: context,
        onRequestShare: _requestSharedVehicleAccess,
        onClaimOwnership: () => setState(() => _currentStep = 4),
      );
    } else {
      setState(() {
        isVehicleExists = false;
        _currentStep++;
      });
    }
  }

  Future<void> _requestSharedVehicleAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final success = await _vehicleService.requestSharedVehicleAccess(registrationController.text, token);
    if (success) {
      await showVerificationCodeDialog(
        context: context,
        verificationCodeController: verificationCodeController,
        onConfirmCode: _confirmSharedVehicleAccess,
      );
    } else {
      await showSimpleMessageDialog(context: context, message: 'Erreur lors de la demande.');
    }
  }

  Future<void> _confirmSharedVehicleAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final success = await _vehicleService.confirmSharedVehicleAccess(
      registrationController.text,
      verificationCodeController.text,
      token,
    );

    if (success) {
      await showSimpleMessageDialog(context: context, message: 'Accès partagé accordé.', isSuccess: true);
    } else {
      await showSimpleMessageDialog(context: context, message: 'Erreur de vérification.');
    }
  }

  Future<void> _addVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final success = await _vehicleService.addVehicle({
      "registrationNumber": registrationController.text,
      "country": selectedCountry,
      "brand": brandController.text,
      "model": modelController.text,
      "year": yearController.text,
    }, token);

    if (success) {
      await showSimpleMessageDialog(context: context, message: 'Véhicule ajouté.', isSuccess: true);
    } else {
      await showSimpleMessageDialog(context: context, message: 'Erreur lors de l\'ajout.');
    }
  }

  Future<void> _claimOwnership() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return;

    final success = await _vehicleService.claimVehicleOwnership(
      registrationController.text,
      token,
    );

    if (success) {
      await showSimpleMessageDialog(context: context, message: 'Propriété réclamée.', isSuccess: true);
    } else {
      await showSimpleMessageDialog(context: context, message: 'Erreur lors de la réclamation.');
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (registrationController.text.isEmpty) {
        showSimpleMessageDialog(context: context, message: "Veuillez entrer une immatriculation.");
        return;
      }
      _checkVehicleExists();
    } else if (_currentStep == 1 && !isVehicleExists) {
      setState(() => _currentStep++);
    } else if (_currentStep == 2 && !isVehicleExists) {
      setState(() => _currentStep++);
    } else if (_currentStep == 4 && isVehicleExists) {
      // step for claiming ownership
    }
  }

  void _skipStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep++);
    }
  }

  void _handleExtractedText(String extractedText) {
  final formattedInput = registrationController.text.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final formattedExtracted = extractedText.replaceAll(RegExp(r'[^A-Z0-9]'), '');

  if (formattedExtracted.contains(formattedInput)) {
    debugPrint('OCR SUCCESS: Matched $formattedInput inside extracted text.');
    ocrFailureCount = 0; // ✅ Remettre à zéro en cas de succès
  } else {
    ocrFailureCount++;
    if (ocrFailureCount >= 3) {
      showContactSupportDialog(context); // 🆕 Nouvelle boîte
      ocrFailureCount = 0; // ✅ Reset compteur après l'alerte
    } else {
      showSimpleMessageDialog(
        context: context,
        message: "Le numéro d'immatriculation détecté ne correspond pas à celui saisi.\n\nVeuillez réessayer.",
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset('lib/assets/images/logobluesigar.png', height: 60),
            ),
            const SizedBox(height: 10),
            Text(
              _getStepTitle(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF013781)),
            ),
            const SizedBox(height: 30),
            _getStepContent(),
            const SizedBox(height: 40),
            StepActions(
              currentStep: _currentStep,
              isVehicleExists: isVehicleExists,
              onSkipStep: _skipStep,
              onAddVehicle: _addVehicle,
              onClaimOwnership: _claimOwnership,
              onNextStep: _nextStep,
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Ajoutez votre immatriculation';
      case 1:
        return 'Ajoutez votre modèle';
      case 2:
        return 'Confirmez votre véhicule';
      case 4:
        return 'Réclamer la propriété';
      default:
        return '';
    }
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return StepRegistration(
          registrationController: registrationController,
          isRegistrationValid: true,
          selectedCountry: selectedCountry,
          onCountrySelected: (country) => setState(() => selectedCountry = country),
          onRegistrationChanged: (reg) => registrationController.text = reg,
        );
      case 1:
        return StepCarDetails(
          brandController: brandController,
          modelController: modelController,
          yearController: yearController,
          brands: brands,
          models: models,
          years: years,
          onBrandSelected: (brand) {
            brandController.text = brand;
            fetchModels(brand);
          },
          onModelSelected: (model) => modelController.text = model,
          onYearSelected: (year) => yearController.text = year,
        );
      case 2:
        return StepDocumentUpload(
          capturedImage: capturedImage,
          onImageCaptured: (file) => setState(() => capturedImage = file),
          onTextExtracted: _handleExtractedText, // 🆕 OCR listener branché ici
        );
      case 4:
        return StepClaimOwnership(
          registrationNumber: registrationController.text,
          capturedImage: capturedImage,
          onImageCaptured: (file) => setState(() => capturedImage = file),
        );
      default:
        return const SizedBox();
    }
  }
}
