import 'package:flutter/material.dart';

class CameraIdleView extends StatelessWidget {
  final VoidCallback onTomarFoto;

  const CameraIdleView({super.key, required this.onTomarFoto});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 72,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Escanear Comprobante',
                  style: TextStyle(color: Color(0xFF263238), fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toma una foto clara del comprobante para registrarlo automáticamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF78909C), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onTomarFoto,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('ABRIR CÁMARA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}