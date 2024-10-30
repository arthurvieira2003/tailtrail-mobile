import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class ApiService {
  static const String baseUrl = 'http://148.113.172.140:7070';

  Future<void> sendLocation(LocationModel location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dadosGPS'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': location.latitude,
          'longitude': location.longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao enviar localização: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
