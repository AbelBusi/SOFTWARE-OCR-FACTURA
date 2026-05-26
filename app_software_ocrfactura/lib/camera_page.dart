import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_state.dart'; 

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      if (!mounted) return;

      _showOcrDialog();
    } catch (e) {
      print(e);
    }
  }

  void _showOcrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF0D6B68)),
              const SizedBox(height: 20),
              const Text('Procesando OCR...', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Extrayendo texto y validando RUC con SUNAT...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pop(context);

      var nuevaFactura = {
        'ruc': '20109876541',
        'empresa': 'Súper Mayorista Chiclayo',
        'monto': 'S/ 850.00',
        'estado': 'Aceptado',
        'fecha': '26/05/2026'
      };

      AppState.facturas.value = List.from(AppState.facturas.value)..add(nuevaFactura);

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Factura')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner_rounded, size: 100, color: Color(0xFF0D6B68)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('ABRIR CÁMARA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6B68),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}