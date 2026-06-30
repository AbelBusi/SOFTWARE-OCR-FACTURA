class LoginResponse {

  final String accessToken;
  final String tokenType;
  final Usuario usuario;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.usuario,
  });


  factory LoginResponse.fromJson(Map<String,dynamic> json){

    return LoginResponse(
      accessToken: json["access_token"],
      tokenType: json["token_type"],
      usuario: Usuario.fromJson(json["usuario"]),
    );

  }

}


class Usuario {

  final int idUsuario;
  final String dni;
  final String nombres;
  final String apellidos;
  final String correo;


  Usuario({
    required this.idUsuario,
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.correo,
  });


  factory Usuario.fromJson(Map<String,dynamic> json){

    return Usuario(
      idUsuario: json["id_usuario"],
      dni: json["dni"],
      nombres: json["nombres"],
      apellidos: json["apellidos"],
      correo: json["correo"],
    );

  }

}