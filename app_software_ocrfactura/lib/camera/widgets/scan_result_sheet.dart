import 'package:flutter/material.dart';
import '../../models/ocr_result.dart';

class ScanResultSheet extends StatelessWidget {
  final OcrUploadResult resultado;

  const ScanResultSheet({super.key, required this.resultado});

  static void show(BuildContext context, OcrUploadResult resultado) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1565C0), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Factura Registrada',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF263238),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Factura: #${resultado.idFactura}',
                  style: const TextStyle(color: Color(0xFF78909C), fontSize: 13),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        resultado.empresa.nombre.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                      ),
                      const SizedBox(height: 4),
                      Text('RUC: ${resultado.empresa.ruc}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF78909C))),
                      Text(resultado.empresa.direccion,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      Text(
                        '${resultado.factura.tipoComprobante}  ${resultado.factura.numeroComprobante}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0)),
                      ),
                      Text('Fecha: ${resultado.factura.fechaEmision}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      ...resultado.detalles.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Text(d.descripcion,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF263238))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                d.cantidad % 1 == 0
                                    ? 'x${d.cantidad.toInt()}'
                                    : 'x${d.cantidad}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'S/ ${d.subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                          Text(
                            'S/ ${resultado.factura.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}