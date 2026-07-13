import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/factura.dart';
import 'token_storage.dart';
import '../models/factura_detalle.dart';

class FacturaService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Factura>> getFacturasUsuario(
    int idUsuario, {
    String? q,
    String? fecha,
  }) async {
    final token = await TokenStorage.getToken();

    // Solo se envían los filtros con valor; sin ellos se listan todas.
    final params = <String, String>{};
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    if (fecha != null && fecha.isNotEmpty) params['fecha'] = fecha;

    final uri = Uri.parse('$baseUrl/factura/usuario/$idUsuario')
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => Factura.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      throw Exception('Error al obtener comprobantes (${response.statusCode})');
    }
  }

  static Future<FacturaDetalle> getDetalleFactura(int idFactura) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/factura/$idFactura/detalles'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return FacturaDetalle.fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else {
      throw Exception('Error al obtener el detalle (${response.statusCode})');
    }
  }

}



