import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  DateTime? _fecha;

  @override
  void initState() {
    super.initState();
    _futureFacturas = _cargarFacturas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _hayFiltros => _searchCtrl.text.trim().isNotEmpty || _fecha != null;

  Future<List<Factura>> _cargarFacturas() async {
    final idUsuario = await TokenStorage.getUserId();
    if (idUsuario == null) {
      throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
    }
    return FacturaService.getFacturasUsuario(
      idUsuario,
      q: _searchCtrl.text,
      fecha: _fecha != null ? _fmtFecha(_fecha!) : null,
    );
  }

  String _fmtFecha(DateTime d) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${dos(d.month)}-${dos(d.day)}';
  }

  void _recargar() {
    setState(() {
      _futureFacturas = _cargarFacturas();
    });
  }

  Future<void> _refrescar() async {
    final futuro = _cargarFacturas();
    setState(() => _futureFacturas = futuro);
    try {
      await futuro;
    } catch (_) {}
  }

  // La búsqueda por texto se debouncea para no consultar en cada tecla.
  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _recargar);
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? ahora,
      firstDate: DateTime(2020),
      lastDate: DateTime(ahora.year + 1),
    );
    if (elegida != null) {
      setState(() => _fecha = elegida);
      _recargar();
    }
  }

  void _limpiarFiltros() {
    _debounce?.cancel();
    _searchCtrl.clear();
    setState(() => _fecha = null);
    _recargar();
  }

  void _mostrarSnack(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF263238),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Menú para elegir el formato de exportación (PDF o Excel).
  void _mostrarOpcionesExportar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Exportar listado',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF263238))),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFC62828)),
              title: const Text('Exportar a PDF'),
              onTap: () {
                Navigator.pop(ctx);
                _exportar('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_on_rounded,
                  color: Color(0xFF2E7D32)),
              title: const Text('Exportar a Excel'),
              onTap: () {
                Navigator.pop(ctx);
                _exportar('excel');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _exportar(String formato) async {
    // Evita exportar un reporte vacío usando los datos ya cargados.
    try {
      final actuales = await _futureFacturas;
      if (actuales.isEmpty) {
        _mostrarSnack('No hay comprobantes para exportar.');
        return;
      }
    } catch (_) {
      _mostrarSnack('No se pudo preparar la exportación.');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final idUsuario = await TokenStorage.getUserId();
      if (idUsuario == null) {
        throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
      }

      final resultado = await FacturaService.exportarFacturas(
        idUsuario: idUsuario,
        formato: formato,
        q: _searchCtrl.text,
        fecha: _fecha != null ? _fmtFecha(_fecha!) : null,
      );

      if (!mounted) return;
      Navigator.pop(context); // cierra el indicador de carga

      _mostrarSnack(resultado.enDescargas
          ? 'Reporte guardado en Descargas.'
          : 'Reporte generado. Usa Compartir para guardarlo.');

      await Share.shareXFiles(
        [XFile(resultado.rutaCompartir)],
        subject: 'Reporte de comprobantes',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // cierra el indicador de carga
      _mostrarSnack(e.toString().replaceFirst('Exception: ', ''));
    }
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
        actions: [
          IconButton(
            tooltip: 'Exportar',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _mostrarOpcionesExportar,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: RefreshIndicator(
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
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Text(
                            _hayFiltros
                                ? 'No se encontraron comprobantes con esos filtros'
                                : 'Aún no tienes comprobantes registrados',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF78909C)),
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
                          side:
                              const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                        ),
                        child: ListTile(
                          onTap: () =>
                              InvoiceDetailSheet.show(context, f.idFactura),
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
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF78909C)),
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            'S/ ${f.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF263238)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final fechaLabel =
        _fecha != null ? _fmtFecha(_fecha!) : 'Fecha';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
            decoration: InputDecoration(
              hintText: 'Buscar por proveedor, RUC o N° comprobante',
              hintStyle:
                  const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Color(0xFF78909C)),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF78909C), size: 20),
                      onPressed: () {
                        _searchCtrl.clear();
                        _recargar();
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF2F5F9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1565C0), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(fechaLabel,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _fecha != null
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF78909C),
                    side: BorderSide(
                        color: _fecha != null
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFE0E0E0)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (_hayFiltros) ...[
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
