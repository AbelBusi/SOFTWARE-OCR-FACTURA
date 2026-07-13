import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class TypeDistributionCard extends StatelessWidget {
  final Map<String, double> montoPorTipo;

  const TypeDistributionCard({super.key, required this.montoPorTipo});

  static const List<Color> _paleta = [
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
    Color(0xFF90CAF9),
    Color(0xFFB0BEC5),
  ];

  @override
  Widget build(BuildContext context) {
    final entradas = montoPorTipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entradas.fold<double>(0, (s, e) => s + e.value);
    final maxVal = entradas.isEmpty
        ? 1.0
        : entradas.first.value.clamp(1.0, double.infinity);

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
              const Icon(Icons.donut_large_rounded, size: 18, color: Color(0xFF1565C0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('spend_by_type'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (entradas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.tr('no_data'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
            )
          else
            ...List.generate(entradas.length, (i) {
              final e = entradas[i];
              final color = _paleta[i % _paleta.length];
              final porcentaje = total > 0 ? (e.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF263238)),
                          ),
                        ),
                        Text(
                          'S/ ${e.value.toStringAsFixed(2)}  ·  ${porcentaje.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF546E7A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (e.value / maxVal).clamp(0.02, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFECEFF1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
