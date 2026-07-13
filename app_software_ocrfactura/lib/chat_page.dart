import 'package:flutter/material.dart';
import 'models/chat_message.dart';
import 'services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _mensajes = [
    ChatMessage(
      texto:
          'Hola, soy tu asistente. Puedo ayudarte con tus facturas, empresas, RUC, totales, productos, fechas y estadísticas. ¿Qué necesitas saber?',
      esUsuario: false,
    ),
  ];

  bool _cargando = false;

  static const _azul = Color(0xFF1565C0);

  static const _sugerencias = [
    '¿Cuánto he gastado en total?',
    '¿Cuántas facturas tengo?',
    '¿Cuál es mi última factura?',
    '¿En qué empresa gasté más?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarTexto(String texto) async {
    _controller.text = texto;
    await _enviar();
  }

  Future<void> _enviar() async {
    final pregunta = _controller.text.trim();
    if (pregunta.isEmpty || _cargando) return;

    final historial = List<ChatMessage>.from(_mensajes);

    setState(() {
      _mensajes.add(ChatMessage(texto: pregunta, esUsuario: true));
      _cargando = true;
    });
    _controller.clear();
    _bajar();

    try {
      final respuesta = await ChatService.preguntar(
        pregunta: pregunta,
        historial: historial,
      );
      if (!mounted) return;
      setState(() {
        _mensajes.add(ChatMessage(texto: respuesta, esUsuario: false));
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensajes.add(ChatMessage(
          texto: e.toString().replaceFirst('Exception: ', ''),
          esUsuario: false,
        ));
        _cargando = false;
      });
    }
    _bajar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: _azul,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: const [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.support_agent_rounded, color: _azul, size: 22),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Asistente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF69F0AE)),
                    SizedBox(width: 6),
                    Text('En línea',
                        style: TextStyle(
                            fontSize: 11.5, color: Color(0xFFE3F2FD))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length + (_cargando ? 1 : 0),
              itemBuilder: (context, index) {
                if (_cargando && index == _mensajes.length) {
                  return _burbujaEscribiendo();
                }
                return _burbuja(_mensajes[index]);
              },
            ),
          ),
          if (_mensajes.length <= 1 && !_cargando) _sugerenciasBar(),
          _barraEntrada(),
        ],
      ),
    );
  }

  Widget _sugerenciasBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F9FC),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _sugerencias.map((s) {
          return ActionChip(
            label: Text(s, style: const TextStyle(fontSize: 12, color: _azul)),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFBBDEFB)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            onPressed: () => _enviarTexto(s),
          );
        }).toList(),
      ),
    );
  }

  Widget _burbuja(ChatMessage m) {
    final esBot = !m.esUsuario;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            esBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (esBot) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.support_agent_rounded, size: 16, color: _azul),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: esBot ? Colors.white : _azul,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esBot ? 4 : 16),
                  bottomRight: Radius.circular(esBot ? 16 : 4),
                ),
                border:
                    esBot ? Border.all(color: const Color(0xFFE0E0E0)) : null,
              ),
              child: Text(
                m.texto,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: esBot ? const Color(0xFF263238) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _burbujaEscribiendo() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.support_agent_rounded, size: 16, color: _azul),
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _azul),
            ),
          ),
          Text('Escribiendo...',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF78909C))),
        ],
      ),
    );
  }

  Widget _barraEntrada() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Escribe tu pregunta...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF2F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _azul, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _enviar(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: _azul,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _cargando ? null : _enviar,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _cargando ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
