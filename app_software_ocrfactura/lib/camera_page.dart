import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/ocr_result.dart';
import 'services/ocr_service.dart';
import 'services/token_storage.dart';
import 'camera/widgets/processing_animation.dart';
import 'camera/widgets/scan_result_sheet.dart';
import 'camera/widgets/camera_idle_view.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return;

      setState(() {
        _isProcessing = true;
      });

      final idUsuario = await TokenStorage.getUserId();
      if (idUsuario == null) {
        throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
      }

      final resultado = await OcrService.subirImagen(
        rutaImagen: photo.path,
        idUsuario: idUsuario,
      );

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScanResultSheet.show(context, resultado);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF263238),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Escanear Factura', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isProcessing
              ? const Center(child: ProcessingAnimation())
              : CameraIdleView(onTomarFoto: _takePicture),
        ),
      ),
    );
  }
}