import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class StatsRow extends StatelessWidget {
  final int facturas;
  final int albaranes;
  final int otros;

  const StatsRow({
    super.key,
    required this.facturas,
    required this.albaranes,
    required this.otros,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icono: Icons.description_rounded,
            color: const Color(0xFF1565C0),
            label: context.tr('stat_invoices'),
            valor: '$facturas',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icono: Icons.article_outlined,
            color: const Color(0xFF1976D2),
            label: context.tr('stat_delivery'),
            valor: '$albaranes',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icono: Icons.inventory_2_outlined,
            color: const Color(0xFF42A5F5),
            label: context.tr('stat_others'),
            valor: '$otros',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String label;
  final String valor;

  const _StatCard({
    required this.icono,
    required this.color,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF78909C)),
          ),
        ],
      ),
    );
  }
}