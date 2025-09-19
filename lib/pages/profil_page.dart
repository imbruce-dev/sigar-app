import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber = '';
  String _country = '';
  String _token = '';
  final TextEditingController _newFirstNameController = TextEditingController();
  final TextEditingController _newLastNameController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPhoneNumberController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _editingFirstName = false;
  bool _editingLastName = false;
  bool _editingEmail = false;
  bool _editingPhoneNumber = false;
  bool _changingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? '';
      _lastName = prefs.getString('lastName') ?? '';
      _email = prefs.getString('email') ?? '';
      _phoneNumber = prefs.getString('phoneNumber') ?? '';
      _country = prefs.getString('country') ?? '';
      _token = prefs.getString('authToken') ?? '';
    });
  }

  Future<void> _updateProfile(String field, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    var response = await http.patch(
      Uri.parse('http://16.171.22.200:5000/api/users/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(<String, String>{field: value}),
    );

    if (response.statusCode == 200) {
      setState(() {
        switch (field) {
          case 'firstName':
            _firstName = value;
            prefs.setString('firstName', value);
            break;
          case 'lastName':
            _lastName = value;
            prefs.setString('lastName', value);
            break;
          case 'email':
            _email = value;
            prefs.setString('email', value);
            break;
          case 'phoneNumber':
            _phoneNumber = value;
            prefs.setString('phoneNumber', value);
            break;
        }
        _showMessage('Mise à jour réussie.');
      });
    } else {
      _showMessage('Échec de la mise à jour.');
    }
  }

  Future<void> _changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showMessage('Les mots de passe ne correspondent pas.');
      return;
    }
    var response = await http.patch(
      Uri.parse('http://16.171.22.200:5000/api/users/$userId/change-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      _showMessage('Mot de passe modifié avec succès.');
      _logout(); // Déconnexion après le changement de mot de passe
    } else {
      _showMessage('Échec de la modification du mot de passe.');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF013781),
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage(
                    'lib/assets/images/sigar_profil_user.png'),
              ),
            ),
            const SizedBox(height: 16),
            _buildEditableField('Prénom', _firstName, _newFirstNameController,
                _editingFirstName, (value) => _updateProfile('firstName', value)),
            _buildEditableField('Nom', _lastName, _newLastNameController,
                _editingLastName, (value) => _updateProfile('lastName', value)),
            _buildEditableField('Email', _email, _newEmailController,
                _editingEmail, (value) => _updateProfile('email', value)),
            _buildEditableField('Numéro de Téléphone', _phoneNumber,
                _newPhoneNumberController, _editingPhoneNumber,
                (value) => _updateProfile('phoneNumber', value)),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _changingPassword = !_changingPassword;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4266B5),
                minimumSize: const Size(double.infinity, 50), // Hauteur et largeur des boutons
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Light radius
                ),
                foregroundColor: Colors.white,
              ),
              child: const Text('Changer le mot de passe'),
            ),
            if (_changingPassword) ...[
              const SizedBox(height: 10),
              _buildPasswordField('Mot de passe actuel', _oldPasswordController),
              _buildPasswordField('Nouveau mot de passe', _newPasswordController),
              _buildPasswordField('Confirmez le mot de passe',
                  _confirmPasswordController),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4266B5),
                  minimumSize: const Size(double.infinity, 50), // Hauteur et largeur des boutons
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Light radius
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mettre à jour le mot de passe'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 50), // Hauteur et largeur des boutons
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Light radius
                  side: const BorderSide(color: Colors.red), // Bordure rouge
                ),
                foregroundColor: Colors.red, // Couleur du texte rouge
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value,
      TextEditingController controller, bool isEditing, Function(String) onSave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit,
                  color: const Color(0xFF013781)),
              onPressed: () {
                if (isEditing && controller.text.isNotEmpty && controller.text != value) {
                  onSave(controller.text);
                }
                setState(() {
                  isEditing = !isEditing;
                });
              },
            )
          ],
        ),
        isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Entrez votre $label',
                ),
              )
            : Text(value,
                style: const TextStyle(fontSize: 16, color: Colors.black)),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Same radius as other buttons
          ),
          hintText: hint,
        ),
      ),
    );
  }
}
