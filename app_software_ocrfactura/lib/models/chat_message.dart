class ChatMessage {
  final String texto;
  final bool esUsuario;

  ChatMessage({required this.texto, required this.esUsuario});

  String get rol => esUsuario ? 'user' : 'assistant';
}
