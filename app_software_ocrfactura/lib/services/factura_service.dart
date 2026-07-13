import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../api_config.dart';
import '../models/factura.dart';
import 'token_storage.dart';
import 'downloads_saver.dart';
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

  /// Exporta el listado (respetando los filtros) en el formato indicado
  /// ('pdf' o 'excel'). Descarga el archivo, lo guarda en la carpeta pública
  /// Descargas y deja una copia temporal para compartir.
  ///
  /// Devuelve la ruta de la copia a compartir y si se guardó en Descargas
  /// (esto último puede fallar de forma no crítica en dispositivos antiguos).
  static Future<({String rutaCompartir, bool enDescargas})> exportarFacturas({
    required int idUsuario,
    required String formato,
    String? q,
    String? fecha,
  }) async {
    final token = await TokenStorage.getToken();

    final params = <String, String>{'formato': formato};
    if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
    if (fecha != null && fecha.isNotEmpty) params['fecha'] = fecha;

    final uri = Uri.parse('$baseUrl/factura/usuario/$idUsuario/exportar')
        .replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Vuelve a iniciar sesión.');
    } else if (response.statusCode != 200) {
      throw Exception('Error al exportar (${response.statusCode})');
    }

    final esExcel = formato == 'excel';
    final ext = esExcel ? 'xlsx' : 'pdf';
    final mime = esExcel
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/pdf';
    final sello = DateTime.now().millisecondsSinceEpoch;
    final nombre = 'facturas_$sello.$ext';

    // Copia temporal para compartir (share_plus necesita una ruta de archivo).
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$nombre');
    await archivo.writeAsBytes(response.bodyBytes);

    // Guardado en Descargas (no crítico: si falla, igual se puede compartir).
    bool enDescargas = false;
    try {
      await DownloadsSaver.guardar(
        nombre: nombre,
        mime: mime,
        bytes: response.bodyBytes,
      );
      enDescargas = true;
    } catch (_) {
      enDescargas = false;
    }

    return (rutaCompartir: archivo.path, enDescargas: enDescargas);
  }

}



