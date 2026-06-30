import 'package:flutter/material.dart';
import 'app_state.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  void _showInvoiceDetails(BuildContext context, Map<String, String> factura) {
    final esAlerta = factura['estado']!.contains('Alerta');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    color: const Color(0xFFE0E0E0),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: esAlerta ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: esAlerta ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      factura['estado']!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: esAlerta ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE0E0E0), height: 1),
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
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monto Total Total',
                      style: TextStyle(color: Color(0xFF78909C), fontSize: 14),
                    ),
                    Text(
                      factura['monto']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
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
                    backgroundColor: const Color(0xFF1565C0),
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
          Text(label, style: const TextStyle(color: Color(0xFF78909C), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF263238),
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
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
                child: ListTile(
                  onTap: () => _showInvoiceDetails(context, item),
                  leading: CircleAvatar(
                    backgroundColor: esAlerta ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
                    child: Icon(
                      esAlerta ? Icons.error_outline_rounded : Icons.receipt_long_rounded,
                      color: esAlerta ? const Color(0xFFD32F2F) : const Color(0xFF1565C0),
                    ),
                  ),
                  title: Text(
                      item['empresa']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238))
                  ),
                  subtitle: Text(
                      'RUC: ${item['ruc']}\nFecha: ${item['fecha']} • ${item['estado']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF78909C))
                  ),
                  isThreeLine: true,
                  trailing: Text(
                      item['monto']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238))
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}