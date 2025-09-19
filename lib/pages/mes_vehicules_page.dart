import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sigar_header.dart'; // Import SigarHeader
import 'selected_vehicle_page.dart';
import 'vehicule_ajout/vehicule_ajout_page.dart'; // Import pour la navigation

class MesVehiculesPage extends StatefulWidget {
  const MesVehiculesPage({super.key});

  @override
  _MesVehiculesPageState createState() => _MesVehiculesPageState();
}

class _MesVehiculesPageState extends State<MesVehiculesPage> {
  List<dynamic> vehicles = [];
  List<dynamic> filteredVehicles = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.get(
        Uri.parse('http://16.171.22.200:5000/api/vehicles/my-vehicles'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          vehicles = json.decode(response.body);
          filteredVehicles = vehicles;
        });
      } else {
        print('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  void filterVehicles(String query) {
    setState(() {
      filteredVehicles = vehicles.where((vehicle) {
        return vehicle['registrationNumber']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Ajoutez un padding en haut
        child: Column(
          children: [
            const SigarHeader(), // Header personnalisé
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Mes Véhicules',
                style: TextStyle(
                  color: Color(0xFF013781),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par numéro d\'immatriculation',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: filterVehicles,
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehiculeAjoutPage()),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF013781),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/svg/icon-park-solid--add.svg',
                      width: 50, // Ajuster la taille de l'icône si nécessaire
                      height: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Ajoutez un véhicule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Pour suivre vos contraventions.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: filteredVehicles.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredVehicles.length,
                        itemBuilder: (context, index) {
                          var vehicle = filteredVehicles[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectedVehiclePage(
                                    brand: vehicle['brand'] ?? "Inconnu",
                                    model: vehicle['model'] ?? "Inconnu",
                                    year: vehicle['year'] ?? "Inconnue",
                                    vehicleId: vehicle['_id'] ?? "N/A",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              margin: const EdgeInsets.only(right: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: VehicleBox(
                                registrationNumber: vehicle['registrationNumber'] ?? "N/A",
                                brand: vehicle['brand'] ?? "Inconnu",
                                model: vehicle['model'] ?? "Inconnu",
                                year: vehicle['year'] ?? "Inconnue",
                                contraventions: vehicle['contraventions'] ?? [],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleBox extends StatelessWidget {
  final String registrationNumber;
  final String brand;
  final String model;
  final String year;
  final List<dynamic> contraventions;

  const VehicleBox({
    super.key,
    required this.registrationNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.contraventions,
  });

  @override
  Widget build(BuildContext context) {
    bool hasUnpaidContraventions = contraventions.any((c) => c['status'] == 'Non payée');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            'lib/assets/images/mesvehicules.png',
            height: 80,
            width: 80,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registrationNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF013781),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$brand $model, $year',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 5,
                  width: double.infinity,
                  color: hasUnpaidContraventions ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}