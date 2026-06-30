import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ocr_result.dart';
import 'token_storage.dart';

class OcrService {
  static const String baseUrl = "http://192.168.18.4:8000";

  static Future<OcrUploadResult> subirImagen({
    required String rutaImagen,
    required int idUsuario,
  }) async {
    final token = await TokenStorage.getToken();

    final uri = Uri.parse('$baseUrl/ocr/upload').replace(
      queryParameters: {'id_usuario': idUsuario.toString()},
    );

    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('file', rutaImagen));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return OcrUploadResult.fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      String mensaje = 'Error al procesar la imagen (${response.statusCode})';
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