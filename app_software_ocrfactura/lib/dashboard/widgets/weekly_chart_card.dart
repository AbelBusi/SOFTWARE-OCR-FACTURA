import 'package:flutter/material.dart';

class WeeklyChartCard extends StatelessWidget {
  /// Lista de 7 valores, índice 0 = Lunes ... índice 6 = Domingo
  final List<int> conteosPorDia;

  const WeeklyChartCard({super.key, required this.conteosPorDia});

  @override
  Widget build(BuildContext context) {
    final maxVal = conteosPorDia.isEmpty
        ? 1
        : conteosPorDia.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, size: 18, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Frecuencia de Documentos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final valor = conteosPorDia[i];
                final factor = valor / maxVal;
                return _buildBar(dias[i], factor, valor);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String dia, double porcentaje, int valor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          valor > 0 ? '$valor' : '',
          style: const TextStyle(fontSize: 10, color: Color(0xFF78909C), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            width: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF1),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: porcentaje.clamp(0.04, 1.0),
              child: Container(
                width: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dia,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
      ],
    );
  }
}