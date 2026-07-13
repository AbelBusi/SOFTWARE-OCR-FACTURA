import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onEscanear;
  final VoidCallback onHistorial;
  final VoidCallback onAsistente;

  const QuickActionsRow({
    super.key,
    required this.onEscanear,
    required this.onHistorial,
    required this.onAsistente,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _accion(
            icono: Icons.camera_alt_rounded,
            label: 'Escanear',
            onTap: onEscanear,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _accion(
            icono: Icons.receipt_long_rounded,
            label: 'Historial',
            onTap: onHistorial,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _accion(
            icono: Icons.support_agent_rounded,
            label: 'Asistente',
            onTap: onAsistente,
          ),
        ),
      ],
    );
  }

  Widget _accion({
    required IconData icono,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: const Color(0xFF1565C0), size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
