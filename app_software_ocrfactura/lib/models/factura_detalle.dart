class DetalleItem {
  final int idDetalle;
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleItem({
    required this.idDetalle,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return DetalleItem(
      idDetalle: json['id_detalle'] ?? 0,
      descripcion: (json['descripcion'] ?? '').toString(),
      cantidad: toDouble(json['cantidad']),
      precioUnitario: toDouble(json['precio_unitario']),
      subtotal: toDouble(json['subtotal']),
    );
  }
}

class FacturaDetalle {
  final int idFactura;
  final int idUsuario;
  final int idEmpresa;
  final String tipoComprobante;
  final String numeroComprobante;
  final String fechaEmision;
  final double subtotal;
  final double igv;
  final double total;
  final List<DetalleItem> detalles;

  FacturaDetalle({
    required this.idFactura,
    required this.idUsuario,
    required this.idEmpresa,
    required this.tipoComprobante,
    required this.numeroComprobante,
    required this.fechaEmision,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.detalles,
  });

  factory FacturaDetalle.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    final rawDetalles = json['detalles'];
    final List<DetalleItem> items = (rawDetalles is List)
        ? rawDetalles
        .whereType<Map>()
        .map((e) => DetalleItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
        : [];

    return FacturaDetalle(
      idFactura: json['id_factura'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      idEmpresa: json['id_empresa'] ?? 0,
      tipoComprobante: (json['tipo_comprobante'] ?? '').toString(),
      numeroComprobante: (json['numero_comprobante'] ?? '').toString(),
      fechaEmision: (json['fecha_emision'] ?? '').toString(),
      subtotal: toDouble(json['subtotal']),
      igv: toDouble(json['igv']),
      total: toDouble(json['total']),
      detalles: items,
    );
  }
}