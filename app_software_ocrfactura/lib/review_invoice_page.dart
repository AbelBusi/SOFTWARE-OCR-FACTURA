import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/ocr_result.dart';
import 'services/ocr_service.dart';
import 'services/factura_service.dart';

/// Pantalla donde el usuario revisa y corrige los datos de una factura, ya sea
/// tras el OCR (creación) o al editar una factura existente.
class ReviewInvoicePage extends StatefulWidget {
  final OcrUploadResult extraido;
  final int? idUsuario;
  final int? idFactura;
  final double? confianza;
  // Nuevo (registro manual): exige campos clave y permite un título propio.
  final bool camposObligatorios;
  final String? titulo;

  const ReviewInvoicePage({
    super.key,
    required this.extraido,
    this.idUsuario,
    this.idFactura,
    this.confianza,
    this.camposObligatorios = false,
    this.titulo,
  });

  bool get esEdicion => idFactura != null;

  @override
  State<ReviewInvoicePage> createState() => _ReviewInvoicePageState();
}

class _ReviewInvoicePageState extends State<ReviewInvoicePage> {
  final _formKey = GlobalKey<FormState>();

  // Empresa
  late final TextEditingController _rucCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _direccionCtrl;

  // Factura
  late final TextEditingController _tipoCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _subtotalCtrl;
  late final TextEditingController _igvCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _obsCtrl;

  // Detalles
  final List<_DetalleControllers> _detalles = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.extraido.empresa;
    final f = widget.extraido.factura;

    _rucCtrl = TextEditingController(text: e.ruc);
    _nombreCtrl = TextEditingController(text: e.nombre);
    _direccionCtrl = TextEditingController(text: e.direccion);

    _tipoCtrl = TextEditingController(text: f.tipoComprobante);
    _numeroCtrl = TextEditingController(text: f.numeroComprobante);
    _fechaCtrl = TextEditingController(text: f.fechaEmision);
    _subtotalCtrl = TextEditingController(text: _numStr(f.subtotal));
    _igvCtrl = TextEditingController(text: _numStr(f.igv));
    _totalCtrl = TextEditingController(text: _numStr(f.total));
    _obsCtrl = TextEditingController(text: f.observaciones);

    for (final d in widget.extraido.detalles) {
      _detalles.add(_DetalleControllers.fromItem(d, _numStr));
    }
  }

  @override
  void dispose() {
    _rucCtrl.dispose();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _tipoCtrl.dispose();
    _numeroCtrl.dispose();
    _fechaCtrl.dispose();
    _subtotalCtrl.dispose();
    _igvCtrl.dispose();
    _totalCtrl.dispose();
    _obsCtrl.dispose();
    for (final d in _detalles) {
      d.dispose();
    }
    super.dispose();
  }

  static String _numStr(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static double _toDouble(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.')) ?? 0.0;

  String? _validarNumero(String? value) {
    if (value == null || value.trim().isEmpty) return null; // vacío = 0
    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
      return 'Número inválido';
    }
    return null;
  }

  // Solo aplica en registro manual (camposObligatorios): evita guardar vacío.
  String? _validarObligatorio(String? value) {
    if (widget.camposObligatorios && (value == null || value.trim().isEmpty)) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _validarFecha(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
      return 'Formato AAAA-MM-DD';
    }
    return null;
  }

  void _agregarDetalle() {
    setState(() => _detalles.add(_DetalleControllers.empty()));
  }

  void _eliminarDetalle(int index) {
    setState(() {
      _detalles[index].dispose();
      _detalles.removeAt(index);
    });
  }

  Future<void> _guardar({bool forzar = false}) async {
    // La validación solo corre en el primer intento; el reintento tras confirmar
    // un duplicado usa los mismos datos ya validados.
    if (!forzar && !_formKey.currentState!.validate()) {
      _showSnackBar('Revisa los campos marcados en rojo.');
      return;
    }

    setState(() => _isSaving = true);

    final datos = {
      'empresa': {
        'ruc': _rucCtrl.text.trim(),
        'nombre': _nombreCtrl.text.trim(),
        'direccion': _direccionCtrl.text.trim(),
      },
      'factura': {
        'tipo_comprobante': _tipoCtrl.text.trim(),
        'numero_comprobante': _numeroCtrl.text.trim(),
        'fecha_emision': _fechaCtrl.text.trim(),
        'subtotal': _toDouble(_subtotalCtrl.text),
        'igv': _toDouble(_igvCtrl.text),
        'total': _toDouble(_totalCtrl.text),
        'observaciones': _obsCtrl.text.trim(),
      },
      'detalles': _detalles
          .map((d) => {
                'descripcion': d.descripcion.text.trim(),
                'cantidad': _toDouble(d.cantidad.text),
                'precio_unitario': _toDouble(d.precioUnitario.text),
                'subtotal': _toDouble(d.subtotal.text),
              })
          .toList(),
    };

    if (widget.esEdicion) {
      await _actualizar(datos);
      return;
    }

    try {
      final guardado = await OcrService.guardarFactura(
        idUsuario: widget.idUsuario!,
        imagenUrl: widget.extraido.imagenUrl,
        datos: datos,
        forzar: forzar,
      );

      if (!mounted) return;
      Navigator.pop(context, guardado);
    } on FacturaDuplicadaException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final continuar = await _confirmarDuplicado(e.mensaje);
      if (continuar && mounted) {
        await _guardar(forzar: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _actualizar(Map<String, dynamic> datos) async {
    try {
      await FacturaService.actualizarFactura(
        idFactura: widget.idFactura!,
        datos: datos,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Diálogo que informa del duplicado y deja al usuario cancelar o continuar.
  Future<bool> _confirmarDuplicado(String mensaje) async {
    final continuar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.copy_all_rounded,
            color: Color(0xFFF9A825), size: 40),
        title: const Text('Factura duplicada',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '$mensaje\n\n¿Deseas registrarla de todas formas?',
          style: const TextStyle(color: Color(0xFF37474F)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF78909C)),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Registrar igual'),
          ),
        ],
      ),
    );
    return continuar ?? false;
  }

  void _showSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF263238),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
            widget.titulo ??
                (widget.esEdicion ? 'Editar Factura' : 'Revisar Factura'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.confianza != null) ...[
                _confianzaBanner(widget.confianza!),
                const SizedBox(height: 16),
              ],
              _infoBanner(),
              const SizedBox(height: 16),
              _seccion('Empresa', Icons.storefront_rounded, [
                _campo(_rucCtrl, 'RUC'),
                _campo(_nombreCtrl, 'Razón social',
                    validator: _validarObligatorio),
                _campo(_direccionCtrl, 'Dirección'),
              ]),
              const SizedBox(height: 16),
              _seccion('Comprobante', Icons.receipt_long_rounded, [
                _campo(_tipoCtrl, 'Tipo de comprobante',
                    validator: _validarObligatorio),
                _campo(_numeroCtrl, 'Número',
                    validator: _validarObligatorio),
                _campo(_fechaCtrl, 'Fecha de emisión (AAAA-MM-DD)',
                    validator: (v) => _validarObligatorio(v) ?? _validarFecha(v)),
                _campo(_subtotalCtrl, 'Subtotal',
                    numerico: true, validator: _validarNumero),
                _campo(_igvCtrl, 'IGV',
                    numerico: true, validator: _validarNumero),
                _campo(_totalCtrl, 'Total',
                    numerico: true,
                    validator: (v) => _validarObligatorio(v) ?? _validarNumero(v)),
                _campo(_obsCtrl, 'Observaciones'),
              ]),
              const SizedBox(height: 16),
              _seccionDetalles(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _guardar,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving
                      ? 'GUARDANDO...'
                      : (widget.esEdicion
                          ? 'GUARDAR CAMBIOS'
                          : 'CONFIRMAR Y GUARDAR'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confianzaBanner(double confianza) {
    final porcentaje = (confianza * 100).clamp(0, 100);

    late final Color fondo;
    late final Color acento;
    late final IconData icono;
    late final String titulo;

    if (porcentaje >= 90) {
      fondo = const Color(0xFFE8F5E9);
      acento = const Color(0xFF2E7D32);
      icono = Icons.verified_rounded;
      titulo = 'Lectura confiable';
    } else if (porcentaje >= 50) {
      fondo = const Color(0xFFFFF8E1);
      acento = const Color(0xFFF9A825);
      icono = Icons.warning_amber_rounded;
      titulo = 'Revisa con atención';
    } else {
      fondo = const Color(0xFFFFEBEE);
      acento = const Color(0xFFC62828);
      icono = Icons.error_outline_rounded;
      titulo = 'Baja precisión de lectura';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: acento.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, color: acento, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: acento)),
                Text(
                  'Confianza de lectura: ${porcentaje.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF37474F)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF1565C0), size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Revisa y corrige los datos extraídos. Se guardarán tal como los confirmes.',
              style: TextStyle(fontSize: 13, color: Color(0xFF37474F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, IconData icono, List<Widget> hijos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: const Color(0xFF1565C0), size: 22),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238))),
            ],
          ),
          const SizedBox(height: 8),
          ...hijos,
        ],
      ),
    );
  }

  Widget _seccionDetalles() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded,
                  color: Color(0xFF1565C0), size: 22),
              const SizedBox(width: 8),
              const Text('Detalle de ítems',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238))),
              const Spacer(),
              TextButton.icon(
                onPressed: _agregarDetalle,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Añadir'),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0)),
              ),
            ],
          ),
          if (_detalles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Sin ítems. Usa "Añadir" para agregar uno.',
                  style: TextStyle(color: Color(0xFF78909C), fontSize: 13)),
            ),
          for (int i = 0; i < _detalles.length; i++) _detalleItem(i),
        ],
      ),
    );
  }

  Widget _detalleItem(int index) {
    final d = _detalles[index];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Ítem ${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF37474F))),
              const Spacer(),
              InkWell(
                onTap: () => _eliminarDetalle(index),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE53935), size: 20),
              ),
            ],
          ),
          _campo(d.descripcion, 'Descripción'),
          Row(
            children: [
              Expanded(
                child: _campo(d.cantidad, 'Cantidad',
                    numerico: true, validator: _validarNumero),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _campo(d.precioUnitario, 'P. unitario',
                    numerico: true, validator: _validarNumero),
              ),
            ],
          ),
          _campo(d.subtotal, 'Subtotal',
              numerico: true, validator: _validarNumero),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String label, {
    bool numerico = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: numerico
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: numerico
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
            : null,
        style: const TextStyle(fontSize: 14, color: Color(0xFF263238)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF78909C), fontSize: 13),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53935)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Agrupa los controladores de un ítem de detalle editable.
class _DetalleControllers {
  final TextEditingController descripcion;
  final TextEditingController cantidad;
  final TextEditingController precioUnitario;
  final TextEditingController subtotal;

  _DetalleControllers({
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory _DetalleControllers.fromItem(
      OcrDetalleItem item, String Function(double) numStr) {
    return _DetalleControllers(
      descripcion: TextEditingController(text: item.descripcion),
      cantidad: TextEditingController(text: numStr(item.cantidad)),
      precioUnitario: TextEditingController(text: numStr(item.precioUnitario)),
      subtotal: TextEditingController(text: numStr(item.subtotal)),
    );
  }

  factory _DetalleControllers.empty() {
    return _DetalleControllers(
      descripcion: TextEditingController(),
      cantidad: TextEditingController(),
      precioUnitario: TextEditingController(),
      subtotal: TextEditingController(),
    );
  }

  void dispose() {
    descripcion.dispose();
    cantidad.dispose();
    precioUnitario.dispose();
    subtotal.dispose();
  }
}
