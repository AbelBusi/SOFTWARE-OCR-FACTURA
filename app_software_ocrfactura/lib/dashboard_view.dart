import 'package:flutter/material.dart';
import 'models/factura.dart';
import 'services/factura_service.dart';
import 'services/token_storage.dart';
import 'dashboard/widgets/summary_header.dart';
import 'dashboard/widgets/stats_row.dart';
import 'dashboard/widgets/weekly_chart_card.dart';
import 'dashboard/widgets/alerts_card.dart';
import 'dashboard/widgets/recent_invoices_card.dart';
import 'dashboard/widgets/quick_actions_row.dart';
import 'dashboard/widgets/type_distribution_card.dart';
import 'history_view.dart';
import 'chat_page.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Future<List<Factura>> _futureFacturas;

  static const _tiposValidos = ['FACTURA', 'BOLETA', 'TICKET', 'RECIBO', 'ALBARAN'];

  @override
  void initState() {
    super.initState();
    _futureFacturas = _cargar();
  }

  Future<List<Factura>> _cargar() async {
    final idUsuario = await TokenStorage.getUserId();
    if (idUsuario == null) {
      throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
    }
    return FacturaService.getFacturasUsuario(idUsuario);
  }

  Future<void> _refrescar() async {
    setState(() {
      _futureFacturas = _cargar();
    });
  }

  List<int> _conteoPorDia(List<Factura> facturas) {
    final conteos = List<int>.filled(7, 0);
    for (final f in facturas) {
      final fecha = DateTime.tryParse(f.fechaEmision);
      if (fecha != null) {
        conteos[fecha.weekday - 1]++;
      }
    }
    return conteos;
  }

  List<double> _montoPorDia(List<Factura> facturas) {
    final montos = List<double>.filled(7, 0);
    for (final f in facturas) {
      final fecha = DateTime.tryParse(f.fechaEmision);
      if (fecha != null) {
        montos[fecha.weekday - 1] += f.total;
      }
    }
    return montos;
  }

  Map<String, double> _montoPorTipo(List<Factura> facturas) {
    final mapa = <String, double>{};
    for (final f in facturas) {
      final tipo = f.tipoComprobante.trim().isEmpty
          ? 'Sin tipo'
          : f.tipoComprobante.trim();
      mapa[tipo] = (mapa[tipo] ?? 0) + f.total;
    }
    return mapa;
  }

  List<Factura> _alertasDeValidacion(List<Factura> facturas) {
    return facturas.where((f) {
      final tipo = f.tipoComprobante.toUpperCase().trim();
      return !_tiposValidos.contains(tipo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'MÓDULO ANALÍTICO',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                  Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${snapshot.error}'.replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF78909C)),
                    ),
                  ),
                ],
              );
            }

            final facturas = snapshot.data ?? [];
            final total = facturas.fold<double>(0, (s, f) => s + f.total);

            final facturasCount = facturas.where((f) => f.tipoComprobante.toUpperCase() == 'FACTURA').length;
            final albaranesCount = facturas.where((f) => f.tipoComprobante.toUpperCase().contains('ALBARAN')).length;
            final otrosCount = facturas.length - facturasCount - albaranesCount;

            final recientes = List<Factura>.from(facturas)
              ..sort((a, b) => b.idFactura.compareTo(a.idFactura));
            final ultimasCinco = recientes.take(5).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              children: [
                SummaryHeader(total: total, cantidad: facturas.length),
                const SizedBox(height: 16),
                QuickActionsRow(
                  onEscanear: () => Navigator.pushNamed(context, '/camera'),
                  onHistorial: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryView()),
                  ),
                  onAsistente: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatPage()),
                  ),
                ),
                const SizedBox(height: 16),
                StatsRow(
                  facturas: facturasCount,
                  albaranes: albaranesCount,
                  otros: otrosCount,
                ),
                const SizedBox(height: 20),
                TypeDistributionCard(montoPorTipo: _montoPorTipo(facturas)),
                const SizedBox(height: 20),
                WeeklyChartCard(
                  conteosPorDia: _conteoPorDia(facturas),
                  montosPorDia: _montoPorDia(facturas),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Alertas y Validaciones',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 12),
                AlertsCard(alertas: _alertasDeValidacion(facturas)),
                const SizedBox(height: 20),
                RecentInvoicesCard(
                  recientes: ultimasCinco,
                  onVerTodas: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryView()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}