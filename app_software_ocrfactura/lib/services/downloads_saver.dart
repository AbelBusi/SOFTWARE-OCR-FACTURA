import 'package:flutter/services.dart';

/// Guarda archivos en la carpeta pública "Descargas" del dispositivo mediante
/// un canal nativo (MediaStore en Android). Devuelve la ruta/uri del archivo.
class DownloadsSaver {
  static const MethodChannel _channel = MethodChannel('app/downloads');

  static Future<String> guardar({
    required String nombre,
    required String mime,
    required Uint8List bytes,
  }) async {
    final ruta = await _channel.invokeMethod<String>('guardarEnDescargas', {
      'nombre': nombre,
      'mime': mime,
      'bytes': bytes,
    });
    if (ruta == null || ruta.isEmpty) {
      throw Exception('No se pudo guardar en Descargas.');
    }
    return ruta;
  }
}
