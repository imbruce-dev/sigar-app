import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  int currentStep = 0;
  bool isOver18 = false;
  String selectedGender = "";
  String selectedCountryCode = '+33'; // Code par défaut : France
  String selectedCountryFlag = 'lib/assets/images/france_flag.png'; // Drapeau par défaut
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final String baseUrl = 'http://16.171.22.200:5000'; // Votre IP pour le backend

  // Liste des pays disponibles pour la sélection
  final List<Map<String, String>> countries = [
    {'name': 'France', 'code': '+33', 'flag': 'lib/assets/images/france_flag.png'},
    {'name': 'Luxembourg', 'code': '+352', 'flag': 'lib/assets/images/luxembourg_flag.png'},
  ];

  // Ouvre le sélecteur de pays
  void _selectCountry() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ListTile(
              title: const Text('Choisissez votre pays', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(countries[index]['flag']!, width: 30),
                    title: Text(countries[index]['name']!),
                    onTap: () {
                      setState(() {
                        selectedCountryCode = countries[index]['code']!;
                        selectedCountryFlag = countries[index]['flag']!;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void nextStep() {
    setState(() {
      if (currentStep < 2) {
        currentStep++;
      } else {
        _registerUser(); // Lancer l'inscription lorsque l'on est au dernier step
      }
    });
  }

  void previousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  Future<void> _registerUser() async {
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String phoneNumber = _phoneNumberController.text;

    if (password != confirmPassword) {
      _showMessage('Les mots de passe ne correspondent pas');
      return;
    }

    final Map<String, dynamic> userData = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "countryCode": selectedCountryCode,
      "gender": selectedGender,
      "country": selectedCountryCode == '+33' ? 'France' : 'Luxembourg'
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        _showMessage(
          'Bienvenue sur SIGAR, $firstName !\nVotre compte a été créé avec succès.',
          success: true,
        );
      } else {
        _showMessage('Erreur lors de la création de l\'utilisateur');
      }
    } catch (e) {
      _showMessage('Erreur de connexion : ${e.toString()}');
    }
  }

  void _showMessage(String message, {bool success = false}) {
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
                if (success) {
                  Navigator.pushReplacementNamed(context, '/connexion'); // Redirect to the ConnexionPage
                }
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Center(
                          child: Image.asset(
                            'lib/assets/images/logobluesigar.png',
                            height: 120,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      if (currentStep == 0) ...[
                        const Text('Créer un compte', style: TextStyle(color: Color(0xFF013781), fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Renseignez vos coordonnées', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 20),
                        buildPhoneField(),
                        const SizedBox(height: 15),
                        buildEmailField(),
                        const SizedBox(height: 15),
                        buildPasswordField('Mot de passe'),
                        const SizedBox(height: 15),
                        buildPasswordField('Confirmer le mot de passe'),
                      ],
                      if (currentStep == 1) ...[
                        const Text('Entrez vos informations', style: TextStyle(color: Color(0xFF013781), fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Renseignez les informations personnelles', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 20),
                        buildGenderSelection(),
                        const SizedBox(height: 15),
                        buildTextField(_lastNameController, 'Entrez votre Nom'),
                        const SizedBox(height: 15),
                        buildTextField(_firstNameController, 'Entrez votre Prénom'),
                        const SizedBox(height: 15),
                        buildCheckboxField(),
                      ],
                      if (currentStep == 2) ...[
                        const Text('Acceptez nos conditions d\'utilisation', style: TextStyle(color: Color(0xFF013781), fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Merci de lire et accepter les conditions pour continuer.', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 20),
                        buildTermsText(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepIndicator(int step) {
    bool isActive = step == currentStep;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 40,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF013781) : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget buildPhoneField() {
    return Row(
      children: [
        GestureDetector(
          onTap: _selectCountry,
          child: Row(
            children: [
              Image.asset(selectedCountryFlag, width: 30, height: 20),
              const SizedBox(width: 5),
              Text(selectedCountryCode),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget buildPasswordField(String label) {
    return TextField(
      controller: label == 'Mot de passe' ? _passwordController : _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget buildGenderSelection() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text("Monsieur"),
            value: "male",
            groupValue: selectedGender,
            activeColor: const Color(0xFF4266B5),
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text("Madame"),
            value: "female",
            groupValue: selectedGender,
            activeColor: const Color(0xFF4266B5),
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildCheckboxField() {
    return Row(
      children: [
        Checkbox(
          value: isOver18,
          activeColor: const Color(0xFF4266B5),
          onChanged: (value) {
            setState(() {
              isOver18 = value!;
            });
          },
        ),
        const Text("Je confirme avoir plus de 18 ans"),
      ],
    );
  }

  Widget buildTermsText() {
    return const Text(
      'En continuant, vous acceptez les conditions générales d\'utilisation de SIGAR.',
      style: TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  Widget buildContinueButton() {
    return GestureDetector(
      onTap: nextStep,
      child: Container(
        color: const Color(0xFF4266B5),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            currentStep == 2 ? "Créer mon compte" : "Continuer",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
