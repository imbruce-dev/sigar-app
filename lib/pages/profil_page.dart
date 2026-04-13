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

  // ✅ AJOUT : état de suppression
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _newFirstNameController.dispose();
    _newLastNameController.dispose();
    _newEmailController.dispose();
    _newPhoneNumberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? '';
      _lastName = prefs.getString('lastName') ?? '';
      _email = prefs.getString('email') ?? '';
      _phoneNumber = prefs.getString('phoneNumber') ?? '';
      _country = prefs.getString('country') ?? '';
      _token = prefs.getString('authToken') ?? ''; // ✅ JWT récupéré ici
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
      });
      _showMessage('Mise à jour réussie.');
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
      _logout();
    } else {
      _showMessage('Échec de la modification du mot de passe.');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
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

  // ✅ AJOUT : requête suppression compte (Vercel)
  Future<void> _deleteAccount() async {
    if (_token.isEmpty) {
      _showMessage("Session expirée. Reconnecte-toi.");
      return;
    }

    setState(() => _deletingAccount = true);

    try {
      final response = await http.delete(
        Uri.parse('https://sigarbackend.vercel.app/api/delete-account'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _showMessage("Compte supprimé avec succès.");
        await _logout(); // ✅ clear prefs + redirect login
        return;
      }

      // On essaie de lire un message d'erreur éventuel
      String errorMsg = "Échec de la suppression du compte.";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          errorMsg = decoded['error'].toString();
        } else if (decoded is Map && decoded['message'] != null) {
          errorMsg = decoded['message'].toString();
        }
      } catch (_) {}

      _showMessage(errorMsg);
    } catch (e) {
      _showMessage("Erreur réseau. Réessaie.");
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  // ✅ AJOUT : popup confirmation suppression (avec checkbox)
  Future<void> _showDeleteAccountDialog() async {
    bool acknowledged = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text("Supprimer le compte ?"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Cette action est définitive.\n"
                    "Votre compte et vos données associées seront supprimés.",
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: acknowledged,
                        onChanged: (v) {
                          setStateDialog(() => acknowledged = v ?? false);
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Je comprends que cette action est irréversible.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _deletingAccount ? null : () => Navigator.pop(ctx, false),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: (!_deletingAccount && acknowledged)
                      ? () => Navigator.pop(ctx, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: _deletingAccount
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Supprimer"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
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
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage(
                    'lib/assets/images/sigar_profil_user.png'),
              ),
            ),
            const SizedBox(height: 16),

            _buildEditableField(
              'Prénom',
              _firstName,
              _newFirstNameController,
              _editingFirstName,
              (value) => _updateProfile('firstName', value),
              onToggle: (v) => setState(() => _editingFirstName = v),
            ),
            _buildEditableField(
              'Nom',
              _lastName,
              _newLastNameController,
              _editingLastName,
              (value) => _updateProfile('lastName', value),
              onToggle: (v) => setState(() => _editingLastName = v),
            ),
            _buildEditableField(
              'Email',
              _email,
              _newEmailController,
              _editingEmail,
              (value) => _updateProfile('email', value),
              onToggle: (v) => setState(() => _editingEmail = v),
            ),
            _buildEditableField(
              'Numéro de Téléphone',
              _phoneNumber,
              _newPhoneNumberController,
              _editingPhoneNumber,
              (value) => _updateProfile('phoneNumber', value),
              onToggle: (v) => setState(() => _editingPhoneNumber = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _changingPassword = !_changingPassword;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4266B5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.red),
                ),
                foregroundColor: Colors.red,
              ),
              child: const Text('Se déconnecter'),
            ),

            // ✅ AJOUT : Zone suppression de compte
            const SizedBox(height: 20),
            const Divider(height: 28, thickness: 1),
            const Text(
              "Zone dangereuse",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              "Supprimer votre compte effacera définitivement vos données.",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deletingAccount ? null : _showDeleteAccountDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.white,
              ),
              child: _deletingAccount
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Supprimer mon compte"),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ IMPORTANT : correction légère (ton ancien code ne toggle pas bien le bool)
  Widget _buildEditableField(
    String label,
    String value,
    TextEditingController controller,
    bool isEditing,
    Function(String) onSave, {
    required void Function(bool) onToggle,
  }) {
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
                if (!isEditing) {
                  // Préremplir quand on commence à éditer
                  controller.text = value;
                }

                if (isEditing &&
                    controller.text.isNotEmpty &&
                    controller.text != value) {
                  onSave(controller.text);
                }

                // ✅ toggle réel
                onToggle(!isEditing);
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
            borderRadius: BorderRadius.circular(8),
          ),
          hintText: hint,
        ),
      ),
    );
  }
}
