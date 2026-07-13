import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/ocr_result.dart';
import 'token_storage.dart';

/// Se lanza cuando el backend detecta que la factura ya fue registrada (HTTP 409).
/// Permite a la UI ofrecer al usuario cancelar o continuar.
class FacturaDuplicadaException implements Exception {
  final String mensaje;
  FacturaDuplicadaException(this.mensaje);

  @override
  String toString() => mensaje;
}

class OcrService {
  static const String baseUrl = ApiConfig.baseUrl;

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
      throw Exception(_mensajeError(response, 'Error al procesar la imagen'));
    }
  }

  /// Guarda la factura con los datos ya revisados y corregidos por el usuario.
  static Future<OcrUploadResult> guardarFactura({
    required int idUsuario,
    required String imagenUrl,
    required Map<String, dynamic> datos,
    bool forzar = false,
  }) async {
    final token = await TokenStorage.getToken();

    final uri = Uri.parse('$baseUrl/ocr/guardar');

    final body = {
      'id_usuario': idUsuario,
      'imagen_url': imagenUrl,
      'forzar': forzar,
      'empresa': datos['empresa'],
      'factura': datos['factura'],
      'detalles': datos['detalles'],
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return OcrUploadResult.fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode == 409) {
      throw FacturaDuplicadaException(
          _mensajeError(response, 'Esta factura ya fue registrada.'));
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      throw Exception(_mensajeError(response, 'Error al guardar la factura'));
    }
  }

  static String _mensajeError(http.Response response, String fallback) {
    String mensaje = '$fallback (${response.statusCode})';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map && body['detail'] != null) {
        mensaje = body['detail'].toString();
      }
    } catch (_) {}
    return mensaje;
  }
}