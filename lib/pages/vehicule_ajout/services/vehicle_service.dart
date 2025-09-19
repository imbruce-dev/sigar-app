import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service centralisé pour les appels liés aux véhicules
class VehicleService {
  final String _baseUrl = 'http://16.171.22.200:5000/api/vehicles';

  // 🔹 Récupère les marques de voiture depuis CarQuery API
  Future<List<String>> fetchBrands() async {
    final response = await http.get(Uri.parse('https://www.carqueryapi.com/api/0.3/?cmd=getMakes'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['Makes'].map((make) => make['make_display']));
    } else {
      throw Exception('Erreur lors du chargement des marques');
    }
  }

  // 🔹 Récupère les modèles en fonction d'une marque
  Future<List<String>> fetchModels(String brand) async {
    final response = await http.get(Uri.parse('https://www.carqueryapi.com/api/0.3/?cmd=getModels&make=$brand'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['Models'].map((model) => model['model_name']));
    } else {
      throw Exception('Erreur lors du chargement des modèles');
    }
  }

  // 🔹 Vérifie si le véhicule existe
  Future<bool> checkVehicleExists(String registrationNumber, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$registrationNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // 🔹 Demande un accès partagé au véhicule
  Future<bool> requestSharedVehicleAccess(String registrationNumber, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$registrationNumber/request-share'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "registrationNumber": registrationNumber,
      }),
    );

    return response.statusCode == 200;
  }

  // 🔹 Confirme un accès partagé avec code
  Future<bool> confirmSharedVehicleAccess(String registrationNumber, String verificationCode, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/confirm-share'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "registrationNumber": registrationNumber,
        "verificationCode": verificationCode,
      }),
    );

    return response.statusCode == 200;
  }

  // 🔹 Ajoute un nouveau véhicule
  Future<bool> addVehicle(Map<String, dynamic> vehicleData, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(vehicleData),
    );

    return response.statusCode == 201;
  }

  // 🔹 Réclame la propriété d’un véhicule
  Future<bool> claimVehicleOwnership(String registrationNumber, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/claim-ownership'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "registrationNumber": registrationNumber,
      }),
    );

    return response.statusCode == 200;
  }
}
