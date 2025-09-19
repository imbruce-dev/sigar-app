import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PvPonctuellePage extends StatelessWidget {
  final String vehicleId;

  const PvPonctuellePage({super.key, required this.vehicleId});

  Future<List<dynamic>> fetchPVs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      throw Exception("No token found in local storage");
    }

    // Log the request details
    print("Fetching PVs for vehicleId: $vehicleId");

    final response = await http.get(
      Uri.parse('http://16.171.22.200:5000/api/pvs/vehicle/$vehicleId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Log the response details
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Failed to load PVs. Error: ${response.reasonPhrase}");
      throw Exception('Failed to load PVs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des PVs"),
        backgroundColor: const Color(0xFF013781),
      ),
      body: FutureBuilder(
        future: fetchPVs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Log the error details
            print("Error occurred: ${snapshot.error}");
            return const Center(child: Text("Erreur lors du chargement des PVs"));
          } else {
            List<dynamic> pvs = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: pvs.length,
              itemBuilder: (context, index) {
                var pv = pvs[index];
                return ListTile(
                  title: Text("PV #${pv['referenceNumber']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Montant: ${pv['fineAmount']}€"),
                      Text(
                        pv['isPaid'] ? 'Payé' : 'Non payé',
                        style: TextStyle(
                          color: pv['isPaid'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    pv['isMajorated'] ? 'Majoré' : 'Non majoré',
                    style: TextStyle(
                      color: pv['isMajorated'] ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
