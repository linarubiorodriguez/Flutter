import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:5000'));

  static Future<List<dynamic>> getTiposDocumento() async {
    Response response = await _dio.get('/tipo_doc');
    return response.data['tipo_docs'];
  }

  static Future<bool> registerUser(Map<String, dynamic> formData) async {
    Response response = await _dio.post('/signin', data: formData);
    return response.statusCode == 200;
  }
}
