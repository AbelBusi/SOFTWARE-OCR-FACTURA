import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      List<String> lineasDetectadas = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (line.text.trim().isNotEmpty) {
            lineasDetectadas.add(line.text.trim());
          }
        }
      }

      await textRecognizer.close();

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      if (lineasDetectadas.isNotEmpty) {
        _showResultsModal(lineasDetectadas);
      } else {
        _showSnackBar("No se logró identificar ningún texto en la imagen.");
      }

    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar("Error al procesar el reconocimiento de texto.");
    }
  }

  void _showResultsModal(List<String> textoLineas) {
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
          initialChildSize: 0.6,
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
                      const Icon(Icons.abc_rounded, color: Color(0xFF1565C0), size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Texto Identificado',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF263238),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Líneas de texto detectadas de forma local por el motor OCR:',
                    style: TextStyle(color: Color(0xFF78909C), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: textoLineas.length,
                      separatorBuilder: (context, index) => const Divider(color: Color(0xFFE0E0E0)),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            textoLineas[index],
                            style: const TextStyle(
                              color: Color(0xFF263238),
                              fontSize: 14,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
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
                        'Analizando imagen...',
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
                        'Detector de Caracteres',
                        style: TextStyle(color: Color(0xFF263238), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toma una captura limpia para listar las cadenas detectadas.',
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