import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000'));

  static Future<List<dynamic>> getTiposDocumento() async {
    Response response = await _dio.get('/tipo_doc');
    return response.data['tipo_docs'];
  }

  static Future<bool> registerUser(Map<String, dynamic> formData) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(formData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['mensaje'] ?? 'Error desconocido en el registro');
    }
  } catch (e) {
    throw Exception('Error de conexión: ${e.toString()}');
  }
}


}
