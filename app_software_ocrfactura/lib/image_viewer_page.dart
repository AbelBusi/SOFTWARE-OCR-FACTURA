import 'package:flutter/material.dart';
import 'api_config.dart';
import 'services/token_storage.dart';
import 'l10n/app_localizations.dart';

/// Muestra la imagen original de una factura ocupando la pantalla, con zoom.
class ImageViewerPage extends StatelessWidget {
  final int idFactura;

  const ImageViewerPage({super.key, required this.idFactura});

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  @override
  Widget build(BuildContext context) {
    final url = '${ApiConfig.baseUrl}/factura/$idFactura/imagen';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(context.tr('invoice_image'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _headers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 5.0,
              child: Image.network(
                url,
                headers: snapshot.data,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stack) => _sinImagen(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sinImagen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined,
              color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            context.tr('no_image'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
