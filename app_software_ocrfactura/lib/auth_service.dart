import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_software_ocrfactura/api_config.dart';

class AuthService {
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(ApiConfig.login);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Login exitoso: $data');
        return true;
      } else {
        print('Error en el servidor: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión o de red: $e');
      return false;
    }
  }
}