import 'package:flutter/material.dart';
import 'models/factura_detalle.dart';
import 'services/factura_service.dart';

class InvoiceDetailSheet {
  InvoiceDetailSheet._();

  static void show(BuildContext context, int idFactura) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _InvoiceDetailContent(idFactura: idFactura),
    );
  }
}

class _InvoiceDetailContent extends StatefulWidget {
  final int idFactura;

  const _InvoiceDetailContent({required this.idFactura});

  @override
  State<_InvoiceDetailContent> createState() => _InvoiceDetailContentState();
}

class _InvoiceDetailContentState extends State<_InvoiceDetailContent> {
  late Future<FacturaDetalle> _futureDetalle;

  @override
  void initState() {
    super.initState();
    _futureDetalle = FacturaService.getDetalleFactura(widget.idFactura);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder<FacturaDetalle>(
        future: _futureDetalle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  '${snapshot.error}'.replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF78909C)),
                ),
              ),
            );
          }

          final f = snapshot.data!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      f.tipoComprobante.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.numeroComprobante,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha de Emisión: ${f.fechaEmision}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE0E0E0), height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          flex: 5,
                          child: Text('DESCRIPCIÓN',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78909C))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('CANT.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78909C))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('IMPORTE',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78909C))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (f.detalles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Sin ítems detallados',
                          style: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                        ),
                      )
                    else
                      ...f.detalles.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  item.descripcion,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF263238)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.cantidad % 1 == 0
                                      ? item.cantidad.toInt().toString()
                                      : item.cantidad.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF263238)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'S/ ${item.subtotal.toStringAsFixed(2)}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE0E0E0), height: 1),
                    ),
                    _buildTotalRow('Subtotal', f.subtotal),
                    const SizedBox(height: 4),
                    _buildTotalRow('I.G.V.', f.igv),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL GENERAL',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                        ),
                        Text(
                          'S/ ${f.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CERRAR DETALLES'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF78909C))),
        Text(
          'S/ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF263238)),
        ),
      ],
    );
  }
}