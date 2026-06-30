import 'package:flutter/material.dart';
import '../../models/factura.dart';

class AssistantChatCard extends StatefulWidget {
  final List<Factura> facturas;

  const AssistantChatCard({super.key, required this.facturas});

  @override
  State<AssistantChatCard> createState() => _AssistantChatCardState();
}

class _ChatMsg {
  final String texto;
  final bool esBot;
  _ChatMsg(this.texto, this.esBot);
}

class _AssistantChatCardState extends State<AssistantChatCard> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMsg> _mensajes = [
    _ChatMsg('Hola, puedo ayudarte con tus comprobantes. Pregúntame por tu total, cantidad o tu última factura.', true),
  ];

  void _responder(String pregunta) {
    final q = pregunta.toLowerCase();
    String respuesta;

    if (widget.facturas.isEmpty) {
      respuesta = 'Aún no tienes comprobantes registrados.';
    } else if (q.contains('total') || q.contains('gast')) {
      final total = widget.facturas.fold<double>(0, (s, f) => s + f.total);
      respuesta = 'Tu total acumulado es S/ ${total.toStringAsFixed(2)} en ${widget.facturas.length} comprobantes.';
    } else if (q.contains('cuant') || q.contains('cantidad')) {
      respuesta = 'Tienes ${widget.facturas.length} comprobantes registrados.';
    } else if (q.contains('promedio')) {
      final total = widget.facturas.fold<double>(0, (s, f) => s + f.total);
      final prom = total / widget.facturas.length;
      respuesta = 'Tu ticket promedio es S/ ${prom.toStringAsFixed(2)}.';
    } else if (q.contains('ultim') || q.contains('reciente')) {
      final ultima = widget.facturas.reduce((a, b) => a.idFactura > b.idFactura ? a : b);
      respuesta = 'Tu último comprobante es "${ultima.tipoComprobante}" N° ${ultima.numeroComprobante} por S/ ${ultima.total.toStringAsFixed(2)} del ${ultima.fechaEmision}.';
    } else if (q.contains('mayor') || q.contains('más caro') || q.contains('mas caro')) {
      final mayor = widget.facturas.reduce((a, b) => a.total > b.total ? a : b);
      respuesta = 'Tu comprobante más alto es N° ${mayor.numeroComprobante} por S/ ${mayor.total.toStringAsFixed(2)}.';
    } else {
      respuesta = 'No tengo información sobre eso todavía. Prueba preguntando por tu "total", "cantidad", "promedio" o "última factura".';
    }

    setState(() {
      _mensajes.add(_ChatMsg(pregunta, false));
      _mensajes.add(_ChatMsg(respuesta, true));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.support_agent_rounded, size: 18, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text(
                'Asistente de Comprobantes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final m = _mensajes[index];
                return Align(
                  alignment: m.esBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: m.esBot ? const Color(0xFFF7F9FC) : const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(10),
                      border: m.esBot ? Border.all(color: const Color(0xFFE0E0E0)) : null,
                    ),
                    child: Text(
                      m.texto,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: m.esBot ? const Color(0xFF263238) : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu pregunta...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF78909C)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) _responder(v.trim());
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () {
                    final v = _controller.text.trim();
                    if (v.isNotEmpty) _responder(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}