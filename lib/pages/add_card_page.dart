import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddCardPage extends StatefulWidget {
  final String type; // Type de la carte (Visa, MasterCard, etc.)
  final String logoPath; // Chemin du logo
  final Function(Map<String, String>) onAdd; // Fonction de rappel lorsque l'utilisateur ajoute une carte

  const AddCardPage({
    Key? key,
    required this.type,
    required this.logoPath,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF013781),
        title: const Text('Ajouter une carte', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Template de carte mis à jour en temps réel
            _buildCardTemplate(),
            const SizedBox(height: 20),

            // Champ Nom du propriétaire
            _buildInputField(
              controller: _nameController,
              label: 'Nom du propriétaire',
              onChanged: (value) {
                setState(() {}); // Met à jour le template de la carte
              },
            ),
            const SizedBox(height: 10),

            // Champ Numéro de carte
            _buildInputField(
              controller: _cardNumberController,
              label: 'Numéro de la carte',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 16,
              onChanged: (value) {
                setState(() {}); // Met à jour le template de la carte
              },
            ),
            const SizedBox(height: 10),

            // Champ Date d'expiration
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _expiryDateController,
                    label: 'Date d\'expiration (MM/YY)',
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
                    maxLength: 5,
                    onChanged: (value) {
                      setState(() {}); // Met à jour le template de la carte
                    },
                  ),
                ),
                const SizedBox(width: 20),

                // Champ CVV
                Expanded(
                  child: _buildInputField(
                    controller: _cvvController,
                    label: 'CVV',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() {}); // Met à jour le template de la carte
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Vérifier que tous les champs sont remplis
            if (_nameController.text.isNotEmpty &&
                _cardNumberController.text.length == 16 &&
                _expiryDateController.text.length == 5 &&
                _cvvController.text.length == 3) {
              // Appel de la fonction pour ajouter la carte
              widget.onAdd({
                'type': widget.type,
                'logoPath': widget.logoPath,
                'last4': _cardNumberController.text.substring(12),
                'expiryDate': _expiryDateController.text,
              });

              // Retour à la page précédente
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Widget pour afficher le template de la carte
  Widget _buildCardTemplate() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF), // Couleur de fond de la carte
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo de la carte
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(
              widget.logoPath,
              width: 60,
              height: 46, // Adapter la hauteur pour garder le ratio
            ),
          ),
          const Spacer(),
          // Numéro de la carte (4 derniers chiffres seulement)
          Text(
            _cardNumberController.text.isEmpty
                ? '**** **** **** ****'
                : '**** **** **** ${_cardNumberController.text.padRight(16, '*').substring(12)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          // Nom du propriétaire de la carte
          Text(
            _nameController.text.isEmpty ? 'NOM DU TITULAIRE' : _nameController.text.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          // Date d'expiration de la carte
          const SizedBox(height: 5),
          Text(
            _expiryDateController.text.isEmpty ? 'MM/YY' : _expiryDateController.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour créer un champ de saisie
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
