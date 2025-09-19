import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddPVPage extends StatefulWidget {
  const AddPVPage({super.key});

  @override
  _AddPVPageState createState() => _AddPVPageState();
}

class _AddPVPageState extends State<AddPVPage> {
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController infractionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController fineAmountController = TextEditingController();
  final TextEditingController dateOfInfractionController = TextEditingController();
  final TextEditingController timeOfInfractionController = TextEditingController();

  String selectedClass = '1';
  String selectedCountry = 'France';

  final List<String> classes = ['1', '2', '3', '4', '5'];
  final List<String> infractions = [
    'Stationnement interdit',
    'Excès de vitesse entre 20km/h et 40km/h',
    'Non-port de la ceinture de sécurité',
    'Conduite en état d\'ébriété',
    'Utilisation du téléphone au volant',
    'Non-respect d\'un feu rouge',
    'Défaut de présentation des papiers',
    'Vitesse excessive par rapport aux conditions météorologiques',
  ];

  final List<String> addresses = [
    'Boulevard Royal, Luxembourg',
    'Route de Thionville, Metz',
    'Place d\'Armes, Luxembourg',
    'Rue de Rivoli, Paris',
    'Avenue Pasteur, Luxembourg',
    'Boulevard Saint-Germain, Paris',
    'Rue du Fort, Luxembourg',
    'Avenue des Champs-Élysées, Paris',
  ];

  @override
  void initState() {
    super.initState();
    // Set default date
    dateOfInfractionController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default time
    timeOfInfractionController.text = TimeOfDay.now().format(context);
  }

  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        dateOfInfractionController.text = selectedDate.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        timeOfInfractionController.text = selectedTime.format(context);
      });
    }
  }

  Future<void> addPV() async {
    final String registrationNumber = registrationController.text;

    try {
      // Retrieve the token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      // Fetch the vehicle ID using the registration number
      final vehicleResponse = await http.get(
        Uri.parse('http://16.171.22.200:5000/api/vehicles/$registrationNumber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (vehicleResponse.statusCode == 200) {
        final vehicleData = json.decode(vehicleResponse.body);
        String vehicleId = vehicleData['_id'];

        // Prepare PV creation request
        final String infraction = infractionController.text;
        final String address = addressController.text;
        final int fineAmount = int.parse(fineAmountController.text);

        // Format the date and time correctly
        final String dateOfInfraction = '${dateOfInfractionController.text}T${_formatTime(timeOfInfractionController.text)}:00Z';

        final String url = 'http://16.171.22.200:5000/api/pvs/add';

        // Make the POST request to create a PV
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'vehicleId': vehicleId,
            'class': int.parse(selectedClass),
            'infraction': infraction,
            'dateOfInfraction': dateOfInfraction,
            'address': address,
            'fineAmount': fineAmount,
            'countryOfInfraction': selectedCountry,
          }),
        );

        if (response.statusCode == 201) {
          // Show success message with blue background and white text
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Contravention ajoutée avec succès',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF013781),
            ),
          );

          // Reset form fields except date and time
          setState(() {
            registrationController.clear();
            infractionController.clear();
            addressController.clear();
            fineAmountController.clear();
            selectedClass = '1';
            selectedCountry = 'France';
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : ${response.body}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Véhicule non trouvé.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }

  // Helper function to format time
  String _formatTime(String time) {
    // Convert time to 24-hour format
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = hourMinute[1];

    if (timeParts.length > 1 && timeParts[1] == 'PM' && hour < 12) {
      hour += 12; // Convert to 24-hour format
    } else if (timeParts.length > 1 && timeParts[1] == 'AM' && hour == 12) {
      hour = 0; // Midnight case
    }

    return '${hour.toString().padLeft(2, '0')}:${minute}'; // Ensure two digits for hour
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Contravention'),
        backgroundColor: const Color(0xFF013781),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: registrationController,
                decoration: const InputDecoration(labelText: 'Numéro d\'immatriculation'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedClass,
                items: classes
                    .map((e) => DropdownMenuItem(value: e, child: Text('Classe $e')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Classe de la Contravention'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: infractions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    infractionController.text = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Description de l\'Infraction'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: infractionController,
                decoration: const InputDecoration(labelText: 'Description de l\'Infraction (modifiable)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: addresses.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    addressController.text = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Adresse de l\'Infraction'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Adresse de l\'Infraction (modifiable)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fineAmountController,
                decoration: const InputDecoration(labelText: 'Montant de l\'Amende (€)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateOfInfractionController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(labelText: 'Date de l\'Infraction'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeOfInfractionController,
                readOnly: true,
                onTap: _selectTime,
                decoration: const InputDecoration(labelText: 'Heure de l\'Infraction'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addPV,
                child: const Text('Ajouter la Contravention'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
