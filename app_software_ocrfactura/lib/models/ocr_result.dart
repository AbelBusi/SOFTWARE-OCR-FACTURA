class OcrEmpresa {
  final String ruc;
  final String nombre;
  final String direccion;

  OcrEmpresa({required this.ruc, required this.nombre, required this.direccion});

  factory OcrEmpresa.fromJson(Map<String, dynamic> json) {
    return OcrEmpresa(
      ruc: (json['ruc'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
    );
  }
}

class OcrFacturaInfo {
  final String tipoComprobante;
  final String numeroComprobante;
  final String fechaEmision;
  final double subtotal;
  final double igv;
  final double total;

  OcrFacturaInfo({
    required this.tipoComprobante,
    required this.numeroComprobante,
    required this.fechaEmision,
    required this.subtotal,
    required this.igv,
    required this.total,
  });

  factory OcrFacturaInfo.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return OcrFacturaInfo(
      tipoComprobante: (json['tipo_comprobante'] ?? '').toString(),
      numeroComprobante: (json['numero_comprobante'] ?? '').toString(),
      fechaEmision: (json['fecha_emision'] ?? '').toString(),
      subtotal: toDouble(json['subtotal']),
      igv: toDouble(json['igv']),
      total: toDouble(json['total']),
    );
  }
}

class OcrDetalleItem {
  final String descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  OcrDetalleItem({
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory OcrDetalleItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return OcrDetalleItem(
      descripcion: (json['descripcion'] ?? '').toString(),
      cantidad: toDouble(json['cantidad']),
      precioUnitario: toDouble(json['precio_unitario']),
      subtotal: toDouble(json['subtotal']),
    );
  }
}

class OcrUploadResult {
  final int idFactura;
  final OcrEmpresa empresa;
  final OcrFacturaInfo factura;
  final List<OcrDetalleItem> detalles;

  OcrUploadResult({
    required this.idFactura,
    required this.empresa,
    required this.factura,
    required this.detalles,
  });

  factory OcrUploadResult.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    final rawDetalles = data['detalles'];

    return OcrUploadResult(
      idFactura: json['id_factura'] ?? 0,
      empresa: OcrEmpresa.fromJson(Map<String, dynamic>.from(data['empresa'] ?? {})),
      factura: OcrFacturaInfo.fromJson(Map<String, dynamic>.from(data['factura'] ?? {})),
      detalles: (rawDetalles is List)
          ? rawDetalles
          .whereType<Map>()
          .map((e) => OcrDetalleItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],
    );
  }
}