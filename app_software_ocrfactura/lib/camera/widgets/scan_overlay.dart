import 'package:flutter/material.dart';

/// Overlay de guía de captura estilo escáner (Microsoft Lens / Adobe Scan):
/// oscurece el fondo, deja un recuadro guía centrado con esquinas visibles y
/// una línea de escaneo animada. El marco cambia de color cuando la factura
/// se detecta correctamente alineada.
class ScanOverlay extends StatelessWidget {
  /// Posición vertical de la línea de escaneo dentro del recuadro (0.0 a 1.0).
  final double scanProgress;

  /// Indica si la factura está bien encuadrada (colorea el marco de verde).
  final bool aligned;

  const ScanOverlay({
    super.key,
    required this.scanProgress,
    required this.aligned,
  });

  /// Calcula el recuadro guía centrado, con proporción de hoja vertical.
  static Rect guideRect(Size size) {
    final width = size.width * 0.84;
    double height = width * 1.30;
    final maxHeight = size.height * 0.62;
    if (height > maxHeight) height = maxHeight;

    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2 - size.height * 0.04;
    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ScanOverlayPainter(scanProgress: scanProgress, aligned: aligned),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanProgress;
  final bool aligned;

  static const Color _idleColor = Colors.white;
  static const Color _alignedColor = Color(0xFF00E676);
  static const double _radius = 18;
  static const double _cornerLen = 30;
  static const double _cornerWidth = 4;

  _ScanOverlayPainter({required this.scanProgress, required this.aligned});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = ScanOverlay.guideRect(size);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));
    final accent = aligned ? _alignedColor : _idleColor;

    // Fondo oscurecido con el recuadro guía "recortado".
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Borde tenue del recuadro.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent.withValues(alpha: 0.5),
    );

    _drawCorners(canvas, rect, accent);
    if (!aligned) _drawScanLine(canvas, rect);
  }

  void _drawCorners(Canvas canvas, Rect r, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cornerWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    void corner(Offset p, Offset h, Offset v) {
      canvas.drawLine(p, p + h, paint);
      canvas.drawLine(p, p + v, paint);
    }

    corner(r.topLeft, const Offset(_cornerLen, 0), const Offset(0, _cornerLen));
    corner(r.topRight, const Offset(-_cornerLen, 0), const Offset(0, _cornerLen));
    corner(r.bottomLeft, const Offset(_cornerLen, 0), const Offset(0, -_cornerLen));
    corner(r.bottomRight, const Offset(-_cornerLen, 0), const Offset(0, -_cornerLen));
  }

  void _drawScanLine(Canvas canvas, Rect r) {
    final y = r.top + r.height * scanProgress;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x0000E5FF),
          Color(0xFF00E5FF),
          Color(0x0000E5FF),
        ],
      ).createShader(Rect.fromLTWH(r.left, y, r.width, 2))
      ..strokeWidth = 2.5
      ..color = const Color(0xFF00E5FF);

    canvas.drawLine(Offset(r.left + 8, y), Offset(r.right - 8, y), paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.scanProgress != scanProgress || old.aligned != aligned;
}
