import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/ocr_result.dart';
import 'services/ocr_service.dart';
import 'services/token_storage.dart';

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

      _showResultsModal(resultado);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showResultsModal(OcrUploadResult r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(

                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF1565C0), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Factura Registrada',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF263238),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID Factura: #${r.idFactura}',
                    style: const TextStyle(color: Color(0xFF78909C), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          r.empresa.nombre.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                        ),
                        const SizedBox(height: 4),
                        Text('RUC: ${r.empresa.ruc}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF78909C))),
                        Text(r.empresa.direccion,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                        const Divider(height: 24, color: Color(0xFFE0E0E0)),
                        Text(
                          '${r.factura.tipoComprobante}  ${r.factura.numeroComprobante}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0)),
                        ),
                        Text('Fecha: ${r.factura.fechaEmision}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                        const Divider(height: 24, color: Color(0xFFE0E0E0)),
                        ...r.detalles.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(d.descripcion,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF263238))),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  d.cantidad % 1 == 0
                                      ? 'x${d.cantidad.toInt()}'
                                      : 'x${d.cantidad}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'S/ ${d.subtotal.toStringAsFixed(2)}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const Divider(height: 24, color: Color(0xFFE0E0E0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                            Text(
                              'S/ ${r.factura.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: _isProcessing
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1565C0)),
                      SizedBox(height: 24),
                      Text(
                        'Subiendo y procesando factura...',
                        style: TextStyle(color: Color(0xFF78909C), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          size: 80,
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
              if (!_isProcessing)
                ElevatedButton.icon(
                  onPressed: _takePicture,
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
          ),
        ),
      ),
    );
  }
}