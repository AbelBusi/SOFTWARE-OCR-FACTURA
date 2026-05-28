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
        imageQuality: 85, // Optimiza el procesamiento del motor OCR
      );
      
      if (photo == null) return;

      setState(() {
        _isProcessing = true;
      });

      // Inicializar el reconocedor de texto nativo
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      List<String> lineasDetectadas = [];
      
      // Extraer cada línea de texto real identificada por la cámara
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

      // Mostrar el modal con los resultados reales si se detectó algo
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
      backgroundColor: const Color(0xFF1E1E1E),
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
margin: const EdgeInsets.only(bottom: 16),                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.abc_rounded, color: Color(0xFF0D6B68), size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Texto Identificado',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Líneas de texto detectadas de forma local por el motor OCR:',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: textoLineas.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            textoLineas[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'monospace', // Ideal para lectura de datos crudos
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
                      backgroundColor: const Color(0xFF0D6B68),
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
        content: Text(mensaje),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Escanear Factura', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
                            CircularProgressIndicator(color: Color(0xFF0D6B68)),
                            const SizedBox(height: 24),
                            Text(
                              'Analizando imagen...',
                              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0D6B68).withOpacity(0.3), width: 2),
                              ),
                              child: const Icon(
                                Icons.document_scanner_rounded,
                                size: 80,
                                color: Color(0xFF0D6B68),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Detector de Caracteres',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Toma una captura limpia para listar las cadenas detectadas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white60, fontSize: 14),
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
                    backgroundColor: const Color(0xFF0D6B68),
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