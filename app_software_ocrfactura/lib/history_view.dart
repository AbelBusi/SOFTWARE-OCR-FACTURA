import 'package:flutter/material.dart';
import 'app_state.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  void _showInvoiceDetails(BuildContext context, Map<String, String> factura) {
    final esAlerta = factura['estado']!.contains('Alerta');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalle del Comprobante',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: esAlerta ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF0D6B68).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: esAlerta ? Colors.redAccent : const Color(0xFF0D6B68),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      factura['estado']!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: esAlerta ? Colors.redAccent : const Color(0xFF11CAA0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 20),
              _buildDetailRow('Empresa / Razón Social', factura['empresa']!),
              _buildDetailRow('RUC del Emisor', factura['ruc']!),
              _buildDetailRow('Fecha de Emisión', factura['fecha']!),
              _buildDetailRow('Tipo de Documento', 'Factura Electrónica (01)'),
              _buildDetailRow('Moneda', 'Soles (PEN)'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x0FFFFFFF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monto Total Total',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    Text(
                      factura['monto']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                    backgroundColor: const Color(0xFF0D6B68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CERRAR DETALLES'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Comprobantes', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppState.facturas,
        builder: (context, lista, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = lista[(lista.length - 1) - index];
              final esAlerta = item['estado']!.contains('Alerta');
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.white.withOpacity(0.01),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0x0FFFFFFF), width: 1),
                ),
                child: ListTile(
                  onTap: () => _showInvoiceDetails(context, item),
                  leading: CircleAvatar(
                    backgroundColor: esAlerta ? Colors.redAccent.withOpacity(0.1) : const Color(0xFF0D6B68).withOpacity(0.1),
                    child: Icon(
                      esAlerta ? Icons.error_outline_rounded : Icons.receipt_long_rounded,
                      color: esAlerta ? Colors.redAccent : const Color(0xFF0D6B68),
                    ),
                  ),
                  title: Text(item['empresa']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('RUC: ${item['ruc']}\nFecha: ${item['fecha']} • ${item['estado']}', style: const TextStyle(fontSize: 12)),
                  isThreeLine: true,
                  trailing: Text(item['monto']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}