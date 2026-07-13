import 'package:flutter/material.dart';
import '../../models/factura.dart';
import '../../l10n/app_localizations.dart';

class RecentInvoicesCard extends StatelessWidget {
  final List<Factura> recientes;
  final VoidCallback onVerTodas;

  const RecentInvoicesCard({
    super.key,
    required this.recientes,
    required this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 18, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('recent_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                  ),
                ],
              ),
              TextButton(
                onPressed: onVerTodas,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: Text(context.tr('see_all'), style: const TextStyle(fontSize: 12, color: Color(0xFF1565C0))),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE0E0E0)),
          if (recientes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.tr('no_recent'),
                style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
              ),
            )
          else
            ...recientes.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, size: 18, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.tipoComprobante,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                          ),
                          Text(
                            f.fechaEmision,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF78909C)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'S/ ${f.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF263238)),
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