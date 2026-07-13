import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'services/factura_service.dart';

class ExportHelper {
  ExportHelper._();

  static void mostrarOpciones(
    BuildContext context,
    Future<ExportResult> Function(String formato) exportar,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Exportar',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF263238))),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFC62828)),
              title: const Text('Exportar a PDF'),
              onTap: () {
                Navigator.pop(ctx);
                _ejecutar(context, 'pdf', exportar);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.grid_on_rounded, color: Color(0xFF2E7D32)),
              title: const Text('Exportar a Excel'),
              onTap: () {
                Navigator.pop(ctx);
                _ejecutar(context, 'excel', exportar);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Future<void> _ejecutar(
    BuildContext context,
    String formato,
    Future<ExportResult> Function(String formato) exportar,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resultado = await exportar(formato);
      if (!context.mounted) return;
      Navigator.pop(context);

      _mostrarSnack(
          context,
          resultado.enDescargas
              ? 'Reporte guardado en Descargas.'
              : 'Reporte generado. Usa Compartir para guardarlo.');

      await Share.shareXFiles(
        [XFile(resultado.rutaCompartir)],
        subject: 'Reporte de comprobantes',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _mostrarSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static void _mostrarSnack(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF263238),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
