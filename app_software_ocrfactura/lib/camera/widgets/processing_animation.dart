import 'dart:async';
import 'package:flutter/material.dart';

class ProcessingStep {
  final IconData icono;
  final String texto;
  const ProcessingStep(this.icono, this.texto);
}

class ProcessingAnimation extends StatefulWidget {
  const ProcessingAnimation({super.key});

  @override
  State<ProcessingAnimation> createState() => _ProcessingAnimationState();
}

class _ProcessingAnimationState extends State<ProcessingAnimation> {
  static const List<ProcessingStep> _pasos = [
    ProcessingStep(Icons.cloud_upload_rounded, 'Subiendo imagen al servidor'),
    ProcessingStep(Icons.image_search_rounded, 'Analizando el documento'),
    ProcessingStep(Icons.text_fields_rounded, 'Extrayendo texto y montos'),
    ProcessingStep(Icons.fact_check_outlined, 'Validando información'),
    ProcessingStep(Icons.save_rounded, 'Guardando comprobante'),
  ];

  int _pasoActual = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
      if (!mounted) return;
      setState(() {
        _pasoActual = (_pasoActual + 1) % _pasos.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: Icon(
              _pasos[_pasoActual].icono,
              key: ValueKey(_pasoActual),
              size: 56,
              color: const Color(0xFF1565C0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 22,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _pasos[_pasoActual].texto,
              key: ValueKey(_pasoActual),
              style: const TextStyle(
                color: Color(0xFF263238),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pasos.length, (i) {
            final activo = i == _pasoActual;
            final pasado = i < _pasoActual;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activo ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: (activo || pasado)
                    ? const Color(0xFF1565C0)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}