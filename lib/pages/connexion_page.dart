import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  bool isEmailSelected = true; // Par défaut, le mode email est sélectionné
  bool isPasswordVisible = false;
  bool _isLoading = false; // Track loading state for login
  String selectedCountryCode = '+33'; // Code par défaut : France
  String selectedCountryFlag =
      'lib/assets/images/france_flag.png'; // Drapeau par défaut
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String baseUrl =
      'http://16.171.22.200:5000'; // Change this to your backend IP

  // Liste des pays disponibles pour la sélection
  final List<Map<String, String>> countries = [
    {
      'name': 'France',
      'code': '+33',
      'flag': 'lib/assets/images/france_flag.png'
    },
    {
      'name': 'Luxembourg',
      'code': '+352',
      'flag': 'lib/assets/images/luxembourg_flag.png'
    },
  ];

  // Ouvre le sélecteur de pays
  void _selectCountry() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            ListTile(
              title: const Text('Choisissez votre pays',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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

// ConnexionPage: Correct token storage with loading spinner
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String url = '$baseUrl/api/users/login';
    Map<String, dynamic> requestBody;

    // Récupérer le token FCM à partir de SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fcmToken = prefs.getString('fcmToken');

    // Check if login is using email or phone
    if (isEmailSelected) {
      requestBody = {
        "email": _emailController.text,
        "password": _passwordController.text,
        "fcmToken": fcmToken ?? "" // Ajouter le token FCM
      };
    } else {
      requestBody = {
        "phoneNumber": _phoneController.text,
        "password": _passwordController.text,
        "fcmToken": fcmToken ?? "" // Ajouter le token FCM
      };
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Add the role to SharedPreferences after login is successful
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = response.headers['authorization'] ?? '';

        // Store the token and other user information
        await prefs.setString('authToken', token);
        await prefs.setString('userId', data['user']['_id']);
        await prefs.setString('firstName', data['user']['firstName']);
        await prefs.setString('lastName', data['user']['lastName']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setString('phoneNumber', data['user']['phoneNumber']);
        await prefs.setString('countryCode', data['user']['countryCode']);
        await prefs.setString('gender', data['user']['gender']);
        await prefs.setString('country', data['user']['country']);
        await prefs.setString(
            'userRole', data['user']['role']); // Store the role of the user

        // Navigate to home page after successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(
            'Échec de la connexion. Veuillez vérifier vos identifiants.');
      }
    } catch (e) {
      _showMessage('Erreur de connexion : ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading once request is completed
      });
    }
  }

  // Affichage de message d'erreur ou de succès
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
      resizeToAvoidBottomInset:
          true, // Permet d'éviter l'overflow lors de l'apparition du clavier
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
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

              // Bienvenue Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Bienvenue 👋',
                  style: TextStyle(
                    color: Color(0xFF013781), // Blue color for title
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  "Connectez-vous en saisissant votre email ou N° mobile et votre mot de passe.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              // Icône et toggle pour Email/Téléphone
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/svg/mdi--shield-lock.svg',
                        height: 50,
                        color: const Color(0xFF013781),
                      ),
                      const SizedBox(height: 10),
                      // Toggle between Email and Phone
                      Container(
                        width: 250,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color(0xFFEFEFEF),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEmailSelected = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: isEmailSelected
                                        ? const Color(0xFF4266B5)
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        color: isEmailSelected
                                            ? Colors.white
                                            : Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEmailSelected = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: isEmailSelected
                                        ? Colors.transparent
                                        : const Color(0xFF4266B5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Téléphone',
                                      style: TextStyle(
                                        color: isEmailSelected
                                            ? Colors.black54
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Champs Email et Mot de passe si Email est sélectionné
              if (isEmailSelected) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Champ Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            'lib/assets/svg/lets-icons--e-mail.svg',
                            height: 10,
                            fit: BoxFit.scaleDown,
                          ),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Champ Mot de passe
                      TextField(
                        controller: _passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            'lib/assets/svg/octicon--lock-24.svg',
                            height: 10,
                            fit: BoxFit.scaleDown,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Option mot de passe oublié
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Color(0xFF4266B5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Bouton Continuer avec Spinner
                      GestureDetector(
                        onTap: _isLoading ? null : _login, // Disable if loading
                        child: Container(
                          color: _isLoading
                              ? Colors.grey
                              : const Color(0xFF4266B5),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    "Continuer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Lien S'inscrire
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Vous n'avez pas de compte ? ",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                            children: [
                              TextSpan(
                                text: "S'inscrire",
                                style: const TextStyle(
                                  color: Color(0xFF4266B5),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, '/inscription');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Champs Téléphone et Mot de passe si Téléphone est sélectionné
              if (!isEmailSelected) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Sélecteur de pays et champ Téléphone
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _selectCountry,
                            child: Row(
                              children: [
                                Image.asset(
                                  selectedCountryFlag,
                                  width: 30,
                                  height: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(selectedCountryCode),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
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
                      ),
                      const SizedBox(height: 15),
                      // Champ Mot de passe
                      TextField(
                        controller: _passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            'lib/assets/svg/octicon--lock-24.svg',
                            height: 10,
                            fit: BoxFit.scaleDown,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Option mot de passe oublié
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Color(0xFF4266B5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Bouton Continuer avec Spinner
                      GestureDetector(
                        onTap: _isLoading ? null : _login, // Disable if loading
                        child: Container(
                          color: _isLoading
                              ? Colors.grey
                              : const Color(0xFF4266B5),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    "Continuer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Lien S'inscrire
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Vous n'avez pas de compte ? ",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14),
                            children: [
                              TextSpan(
                                text: "S'inscrire",
                                style: const TextStyle(
                                  color: Color(0xFF4266B5),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, '/inscription');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
