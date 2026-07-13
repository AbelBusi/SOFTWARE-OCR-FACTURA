import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api_config.dart';
import '../models/login_response.dart';
import '../models/usuario_perfil.dart';
import 'token_storage.dart';


class AuthService {

  final String baseUrl = ApiConfig.baseUrl;

  Future<UsuarioPerfil> obtenerPerfil(int idUsuario) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/auth/usuario/$idUsuario"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return UsuarioPerfil.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 401) {
      throw Exception("Sesión expirada. Vuelve a iniciar sesión.");
    } else {
      throw Exception("No se pudo cargar tu perfil (${response.statusCode})");
    }
  }

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