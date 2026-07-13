import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/chat_message.dart';
import 'token_storage.dart';

class ChatService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<String> preguntar({
    required String pregunta,
    required List<ChatMessage> historial,
  }) async {
    final token = await TokenStorage.getToken();
    final idUsuario = await TokenStorage.getUserId();
    if (idUsuario == null) {
      throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
    }

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'id_usuario': idUsuario,
              'pregunta': pregunta,
              'historial':
                  historial.map((m) => {'rol': m.rol, 'texto': m.texto}).toList(),
            }),
          )
          .timeout(const Duration(seconds: 35));
    } on TimeoutException {
      throw Exception('El asistente tardó demasiado en responder. Inténtalo de nuevo.');
    } catch (_) {
      throw Exception('No se pudo conectar con el asistente. Revisa tu conexión.');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['respuesta'] ?? '').toString();
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      String mensaje = 'No se pudo obtener respuesta (${response.statusCode})';
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map && body['detail'] != null) {
          mensaje = body['detail'].toString();
        }
      } catch (_) {}
      throw Exception(mensaje);
    }
  }
}
