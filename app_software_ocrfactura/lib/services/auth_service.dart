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


}