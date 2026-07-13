import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class WeeklyChartCard extends StatefulWidget {
  /// Listas de 7 valores, índice 0 = Lunes ... índice 6 = Domingo
  final List<int> conteosPorDia;
  final List<double> montosPorDia;

  const WeeklyChartCard({
    super.key,
    required this.conteosPorDia,
    required this.montosPorDia,
  });

  @override
  State<WeeklyChartCard> createState() => _WeeklyChartCardState();
}

class _WeeklyChartCardState extends State<WeeklyChartCard> {
  bool _porMonto = false;

  static const _azul = Color(0xFF1565C0);
  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final valores = _porMonto
        ? widget.montosPorDia
        : widget.conteosPorDia.map((e) => e.toDouble()).toList();
    final maxVal =
        valores.isEmpty ? 1.0 : valores.reduce((a, b) => a > b ? a : b);
    final maxSeguro = maxVal <= 0 ? 1.0 : maxVal;

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
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: _azul),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('weekly_activity'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
              _toggle(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final valor = valores[i];
                return _buildBar(_dias[i], valor / maxSeguro, valor);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _chip(context.tr('qty'), !_porMonto, () => setState(() => _porMonto = false)),
          _chip(context.tr('amount'), _porMonto, () => setState(() => _porMonto = true)),
        ],
      ),
    );
  }

  Widget _chip(String texto, bool activo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? _azul : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: activo ? Colors.white : const Color(0xFF78909C),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String dia, double factor, double valor) {
    final etiqueta = valor <= 0
        ? ''
        : (_porMonto ? valor.toStringAsFixed(0) : valor.toInt().toString());

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF78909C),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: factor.clamp(0.04, 1.0),
                child: Container(
                  width: 18,
                  decoration: BoxDecoration(
                    color: _azul,
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
      ),
    );
  }
}
