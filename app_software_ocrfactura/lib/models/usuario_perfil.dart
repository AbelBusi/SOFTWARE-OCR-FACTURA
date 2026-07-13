class UsuarioPerfil {
  final int idUsuario;
  final String dni;
  final String nombres;
  final String apellidos;
  final String correo;
  final String fechaNacimiento;
  final String fechaRegistro;

  UsuarioPerfil({
    required this.idUsuario,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.fechaNacimiento,
    required this.fechaRegistro,
  });

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    return UsuarioPerfil(
      idUsuario: json['id_usuario'] ?? 0,
      dni: (json['dni'] ?? '').toString(),
      nombres: (json['nombres'] ?? '').toString(),
      apellidos: (json['apellidos'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      fechaNacimiento: (json['fecha_nacimiento'] ?? '').toString(),
      fechaRegistro: (json['fecha_registro'] ?? '').toString(),
    );
  }

  String get nombreCompleto => '$nombres $apellidos'.trim();

  String get iniciales {
    final n = nombres.isNotEmpty ? nombres[0] : '';
    final a = apellidos.isNotEmpty ? apellidos[0] : '';
    final ini = '$n$a'.toUpperCase();
    return ini.isEmpty ? 'U' : ini;
  }

  String get anioRegistro {
    if (fechaRegistro.length >= 4) return fechaRegistro.substring(0, 4);
    return '-';
  }

  String get fechaRegistroCorta {
    if (fechaRegistro.length >= 10) return fechaRegistro.substring(0, 10);
    return fechaRegistro.isEmpty ? '-' : fechaRegistro;
  }

  String get fechaNacimientoCorta {
    if (fechaNacimiento.length >= 10) return fechaNacimiento.substring(0, 10);
    return fechaNacimiento.isEmpty ? '-' : fechaNacimiento;
  }
}
