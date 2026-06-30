class Factura {
  final int idFactura;
  final int idUsuario;
  final int idEmpresa;
  final String tipoComprobante;
  final String numeroComprobante;
  final String fechaEmision;
  final double subtotal;
  final double igv;
  final double total;

  Factura({
    required this.idFactura,
    required this.idUsuario,
    required this.idEmpresa,
    required this.tipoComprobante,
    required this.numeroComprobante,
    required this.fechaEmision,
    required this.subtotal,
    required this.igv,
    required this.total,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return Factura(
      idFactura: toInt(json['id_factura']),
      idUsuario: toInt(json['id_usuario']),
      idEmpresa: toInt(json['id_empresa']),
      tipoComprobante: (json['tipo_comprobante'] ?? '').toString(),
      numeroComprobante: (json['numero_comprobante'] ?? '').toString(),
      fechaEmision: (json['fecha_emision'] ?? '').toString(),
      subtotal: toDouble(json['subtotal']),
      igv: toDouble(json['igv']),
      total: toDouble(json['total']),
    );
  }
}