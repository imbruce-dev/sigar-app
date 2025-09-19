import 'package:flutter/material.dart';

class CountryPicker extends StatelessWidget {
  final String selectedCountry;
  final Function(String) onCountrySelected;

  const CountryPicker({
    Key? key,
    required this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCountrySelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Image.asset(
              selectedCountry == "France"
                  ? 'lib/assets/images/france_flag.png'
                  : 'lib/assets/images/luxembourg_flag.png',
              width: 30,
            ),
            const SizedBox(width: 10),
            Text(selectedCountry),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showCountrySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Choisissez votre pays',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Image.asset('lib/assets/images/france_flag.png', width: 30),
              title: const Text('France'),
              onTap: () {
                onCountrySelected('France');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/images/luxembourg_flag.png', width: 30),
              title: const Text('Luxembourg'),
              onTap: () {
                onCountrySelected('Luxembourg');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
