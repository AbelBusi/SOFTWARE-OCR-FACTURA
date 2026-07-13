import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'widgets/scan_overlay.dart';

/// Pantalla de captura en vivo con guía visual estilo escáner profesional.
/// Devuelve, vía [Navigator.pop], la ruta de la imagen capturada (String) o
/// null si el usuario cancela. El pipeline posterior (OCR + revisión) no cambia.
class ScannerCameraPage extends StatefulWidget {
  const ScannerCameraPage({super.key});

  @override
  State<ScannerCameraPage> createState() => _ScannerCameraPageState();
}

class _ScannerCameraPageState extends State<ScannerCameraPage>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late final AnimationController _scanCtrl;

  bool _initialized = false;
  bool _capturing = false;
  bool _aligned = false;
  String? _error;

  // Control de la heurística de alineación (evita saturar la CPU).
  bool _detecting = false;
  DateTime _lastDetection = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No se encontró ninguna cámara disponible.');
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      await controller.startImageStream(_procesarFrame);
      setState(() => _initialized = true);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'No se pudo acceder a la cámara. Revisa los permisos.');
      }
    }
  }

  /// Heurística ligera: una factura (papel) llena el encuadro con una superficie
  /// clara y con contraste (texto). Se muestrea el centro del frame de forma
  /// dispersa y throttleada para no afectar el rendimiento.
  void _procesarFrame(CameraImage image) {
    final now = DateTime.now();
    if (_detecting ||
        now.difference(_lastDetection).inMilliseconds < 350 ||
        _capturing) {
      return;
    }
    _detecting = true;
    _lastDetection = now;

    try {
      final plane = image.planes.first; // Plano Y (luminancia) en YUV420.
      final bytes = plane.bytes;
      final rowStride = plane.bytesPerRow;
      final width = image.width;
      final height = image.height;

      final x0 = (width * 0.25).toInt();
      final x1 = (width * 0.75).toInt();
      final y0 = (height * 0.25).toInt();
      final y1 = (height * 0.75).toInt();
      const step = 12;

      double sum = 0;
      double sumSq = 0;
      int count = 0;

      for (int y = y0; y < y1; y += step) {
        final rowStart = y * rowStride;
        for (int x = x0; x < x1; x += step) {
          final lum = bytes[rowStart + x].toDouble();
          sum += lum;
          sumSq += lum * lum;
          count++;
        }
      }

      if (count > 0) {
        final mean = sum / count;
        final variance = (sumSq / count) - (mean * mean);
        final std = variance > 0 ? sqrt(variance) : 0.0;
        // Superficie clara (mean alto) con algo de contenido (std moderado).
        final aligned = mean > 110 && std > 12;
        if (aligned != _aligned && mounted) {
          setState(() => _aligned = aligned);
        }
      }
    } catch (_) {
      // Frame ignorado: la detección es best-effort.
    } finally {
      _detecting = false;
    }
  }

  Future<void> _capturar() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final foto = await controller.takePicture();
      if (!mounted) return;
      Navigator.pop(context, foto.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo capturar la imagen.')),
      );
      // Reanuda la detección para permitir un nuevo intento.
      if (controller.value.isInitialized && !controller.value.isStreamingImages) {
        await controller.startImageStream(_procesarFrame);
      }
    }
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _error != null
          ? _buildError()
          : !_initialized
              ? _buildLoading()
              : _buildScanner(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Iniciando cámara...',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography_rounded,
              color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    final controller = _controller!;
    final preview = controller.value.previewSize!;

    return Stack(
      children: [
        // Preview a pantalla completa (cover). previewSize viene en orientación
        // del sensor (horizontal), por eso se invierten alto/ancho.
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: preview.height,
              height: preview.width,
              child: CameraPreview(controller),
            ),
          ),
        ),

        // Guía visual animada.
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _scanCtrl,
            builder: (context, _) => ScanOverlay(
              scanProgress: _scanCtrl.value,
              aligned: _aligned,
            ),
          ),
        ),

        // Botón de cerrar.
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Indicación contextual + botón de captura.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(_aligned),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _aligned
                            ? Icons.check_circle_rounded
                            : Icons.center_focus_strong_rounded,
                        color: _aligned
                            ? const Color(0xFF00E676)
                            : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _aligned
                            ? '¡Bien encuadrada! Toca para capturar'
                            : 'Coloca la factura dentro del marco',
                        style: TextStyle(
                          color: _aligned
                              ? const Color(0xFF00E676)
                              : Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _capturing ? null : _capturar,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: _aligned
                            ? const Color(0xFF00E676)
                            : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: _capturing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF1565C0),
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded,
                            color: Color(0xFF1565C0), size: 34),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
