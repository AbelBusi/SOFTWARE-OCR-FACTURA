import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/login_response.dart';


class AuthService {

  final String baseUrl = "http://192.168.18.4:8000";

  Future<LoginResponse> login(
      String correo,
      String password
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "correo": correo,
        "password": password
      }),
    );

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return LoginResponse.fromJson(data);
    }

    final error = jsonDecode(response.body);

    throw Exception(
        error["detail"] ?? "Error al iniciar sesión"
    );
  }

  Future<Usuario> register({
    required String dni,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "dni": dni,
        "nombres": nombres,
        "apellidos": apellidos,
        "fecha_nacimiento": fechaNacimiento,
        "correo": correo,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    }

    final error = jsonDecode(response.body);

    throw Exception(
        error["detail"] ?? "Error al registrar usuario"
    );
  }

}