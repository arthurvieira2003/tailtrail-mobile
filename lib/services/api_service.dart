import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<void> sendLocationBatch(LocationBatch batch) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dadosGPS'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(batch.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao enviar localizações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
