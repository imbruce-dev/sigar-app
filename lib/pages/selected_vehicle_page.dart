import 'dart:math'; // For generating random numbers
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SelectedVehiclePage extends StatefulWidget {
  final String brand;
  final String model;
  final String year;
  final String vehicleId; // Vehicle ID to fetch related PVs

  SelectedVehiclePage({
    super.key,
    required this.brand,
    required this.model,
    required this.year,
    required this.vehicleId,
  });

  @override
  _SelectedVehiclePageState createState() => _SelectedVehiclePageState();
}

class _SelectedVehiclePageState extends State<SelectedVehiclePage> {
  String selectedFilter = ''; // To track the selected filter

  // List of vehicle image paths
  final List<String> vehicleImages = [
    'lib/assets/images/model 1.png',
    'lib/assets/images/model 2.png',
    'lib/assets/images/model 3.png',
    'lib/assets/images/model 4.png',
    'lib/assets/images/model 5.png',
    'lib/assets/images/model 6.png',
    'lib/assets/images/model 7.png',
    'lib/assets/images/model 8.png',
  ];

  // Select a random vehicle image from the list
  String getRandomVehicleImage() {
    final random = Random();
    return vehicleImages[random.nextInt(vehicleImages.length)];
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter; // Update the selected filter
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedImage = getRandomVehicleImage(); // Select a random image

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brand} ${widget.model}'), // Title showing the vehicle name
        backgroundColor: const Color(0xFF013781),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the randomly selected vehicle image
          Center(
            child: Image.asset(
              selectedImage,
              height: 300, // Height of the car image
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          // Car details (brand, model, year)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${widget.brand} ${widget.model} (${widget.year})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF013781),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter Buttons
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterButton(label: 'Majoré', onPressed: () => applyFilter('isMajorated=true')),
                FilterButton(label: 'Non majoré', onPressed: () => applyFilter('isMajorated=false')),
                
                FilterButton(label: 'Non payé', onPressed: () => applyFilter('isPaid=false')),
                FilterButton(label: 'Étranger', onPressed: () => applyFilter('origin=foreign')),
                FilterButton(label: 'Local', onPressed: () => applyFilter('origin=local')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tabs for PVs and Payment History
          Expanded(
            child: DefaultTabController(
              length: 2, // Two tabs: Mes PVs, Historique
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFF013781),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF013781),
                    tabs: [
                      Tab(text: "Mes PVs"),
                      Tab(text: "Historique de paiement"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Mes PVs Tab with filters applied
                        MesPvsTab(vehicleId: widget.vehicleId, filter: selectedFilter),
                        // Historique de paiement Tab (placeholder for now)
                        const Center(
                          child: Text("Historique de paiement (Non configuré)"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Filter Button Widget
class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FilterButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF013781), // Updated: Background blue color
          foregroundColor: Colors.white, // Updated: White text color
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// Mes PVs Tab
class MesPvsTab extends StatelessWidget {
  final String vehicleId; // To fetch PVs for this vehicle
  final String filter; // Filter applied by the user

  const MesPvsTab({super.key, required this.vehicleId, required this.filter});

  Future<List<dynamic>> fetchPVs() async {
    // Fetch the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception("No token found in local storage");
    }

    String url = 'http://16.171.22.200:5000/api/pvs/vehicle/$vehicleId';

    // Append filter to URL if a filter is selected
    if (filter.isNotEmpty) {
      url += '?$filter';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the headers
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load PVs');
      }
    } catch (e) {
      throw Exception('Failed to load PVs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPVs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Erreur lors du chargement des PVs"));
        } else {
          List<dynamic> pvs = snapshot.data as List<dynamic>;

          if (pvs.isEmpty) {
            // Display a message when there are no PVs for the given filter
            String message;
            if (filter.contains('isMajorated=true')) {
              message = "Pour l'instant, vous n'avez aucun PV majoré.";
            } else if (filter.contains('isMajorated=false')) {
              message = "Pour l'instant, vous n'avez aucun PV non majoré.";
            } else if (filter.contains('isPaid=true')) {
              message = "Pour l'instant, vous n'avez aucun PV payé.";
            } else if (filter.contains('isPaid=false')) {
              message = "Pour l'instant, vous n'avez aucun PV non payé.";
            } else if (filter.contains('origin=foreign')) {
              message = "Pour l'instant, vous n'avez aucun PV à l'étranger.";
            } else if (filter.contains('origin=local')) {
              message = "Pour l'instant, vous n'avez aucun PV local.";
            } else {
              message = "Pour l'instant, vous n'avez aucun PV.";
            }

            return Center(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: pvs.length,
            itemBuilder: (context, index) {
              var pv = pvs[index];
              return PVBox(
                pv: pv,
              );
            },
          );
        }
      },
    );
  }
}


// Custom PV Box with expandable details and a Pay button for unpaid PVs
class PVBox extends StatefulWidget {
  final dynamic pv; // The PV object containing all its details

  const PVBox({super.key, required this.pv});

  @override
  _PVBoxState createState() => _PVBoxState();
}

class _PVBoxState extends State<PVBox> {
  bool _isExpanded = false; // To track the expanded state of the box

  // Function to format date to human-readable form
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200], // Darkened background color
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text("PV #${widget.pv['referenceNumber']}"),
            subtitle: Text("Montant: ${widget.pv['fineAmount']}€"),
            trailing: Text(
              widget.pv['isMajorated'] ? 'majoré' : 'non majoré',
              style: TextStyle(
                color: widget.pv['isMajorated'] ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded; // Toggle the expanded state
              });
            },
          ),
          // Expanding part showing PV details
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(), // Empty space when collapsed
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Infraction:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013781)),
                      ),
                      Text(widget.pv['infraction']),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date de l'infraction:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013781)),
                      ),
                      Text(formatDate(widget.pv['dateOfInfraction'])),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Adresse:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013781)),
                      ),
                      Text(widget.pv['address']),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date de majoration:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013781)),
                      ),
                      Text(formatDate(widget.pv['majDate'])),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Statut de paiement:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF013781)),
                      ),
                      Text(
                        widget.pv['isPaid'] ? 'Payé' : 'Non payé',
                        style: TextStyle(color: widget.pv['isPaid'] ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // "Pay" button for unpaid PVs
                  if (!widget.pv['isPaid'])
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic for processing payment
                          print("Paying PV #${widget.pv['referenceNumber']}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF013781), // Updated: Button background color
                          foregroundColor: Colors.white, // Updated: Button text color
                        ),
                        child: const Text("Payer"),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
