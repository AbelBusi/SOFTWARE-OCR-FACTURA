import 'package:flutter/material.dart';
import 'models/factura.dart';
import 'services/factura_service.dart';
import 'services/token_storage.dart';
import 'invoice_detail_sheet.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late Future<List<Factura>> _futureFacturas;

  @override
  void initState() {
    super.initState();
    _futureFacturas = _cargarFacturas();
  }

  Future<List<Factura>> _cargarFacturas() async {
    final idUsuario = await TokenStorage.getUserId();
    if (idUsuario == null) {
      throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
    }
    return FacturaService.getFacturasUsuario(idUsuario);
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureFacturas = _cargarFacturas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Historial de Comprobantes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: FutureBuilder<List<Factura>>(
          future: _futureFacturas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${snapshot.error}'.replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF78909C)),
                      ),
                    ),
                  ),
                ],
              );
            }

            final facturas = snapshot.data ?? [];

            if (facturas.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Aún no tienes comprobantes registrados',
                      style: TextStyle(color: Color(0xFF78909C)),
                    ),
                  ),
                ],
              );
            }

            final ordenadas = List<Factura>.from(facturas)
              ..sort((a, b) => b.idFactura.compareTo(a.idFactura));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ordenadas.length,
              itemBuilder: (context, index) {
                final f = ordenadas[index];
                final esAlbaran =
                f.tipoComprobante.toLowerCase().contains('albaran');

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                  child: ListTile(
                    onTap: () => InvoiceDetailSheet.show(context, f.idFactura),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Icon(
                        esAlbaran
                            ? Icons.description_rounded
                            : Icons.receipt_long_rounded,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    title: Text(
                      f.tipoComprobante,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF263238)),
                    ),
                    subtitle: Text(
                      'N° ${f.numeroComprobante}\nFecha: ${f.fechaEmision}',
                      style:
                      const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      'S/ ${f.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                    ),
                  ),
                );
              },
            );          },
        ),
      ),
    );
  }
}