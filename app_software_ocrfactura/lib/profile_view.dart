import 'package:flutter/material.dart';
import 'models/factura.dart';
import 'models/usuario_perfil.dart';
import 'services/auth_service.dart';
import 'services/factura_service.dart';
import 'services/token_storage.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _PerfilData {
  final UsuarioPerfil perfil;
  final List<Factura> facturas;
  _PerfilData(this.perfil, this.facturas);
}

class _ProfileViewState extends State<ProfileView> {
  static const Color _azul = Color(0xFF1565C0);
  static const Color _texto = Color(0xFF263238);
  static const Color _gris = Color(0xFF78909C);
  static const Color _borde = Color(0xFFE0E0E0);
  static const Color _fondoPanel = Color(0xFFFAFAFA);

  late Future<_PerfilData> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_PerfilData> _cargar() async {
    final idUsuario = await TokenStorage.getUserId();
    if (idUsuario == null) {
      throw Exception('No se encontró el usuario. Inicia sesión nuevamente.');
    }
    final perfil = await AuthService().obtenerPerfil(idUsuario);
    final facturas = await FacturaService.getFacturasUsuario(idUsuario);
    return _PerfilData(perfil, facturas);
  }

  Future<void> _refrescar() async {
    setState(() {
      _futuro = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: FutureBuilder<_PerfilData>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.error_outline_rounded, size: 46, color: _gris),
                  const SizedBox(height: 12),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${snapshot.error}'.replaceFirst('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _gris),
                      ),
                    ),
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final perfil = data.perfil;
            final total =
                data.facturas.fold<double>(0, (s, f) => s + f.total);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _header(perfil),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _stat('Comprobantes', '${data.facturas.length}')),
                    const SizedBox(width: 12),
                    Expanded(child: _stat('Total', 'S/ ${total.toStringAsFixed(2)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _stat('Miembro desde', perfil.anioRegistro)),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionHeader('INFORMACIÓN DE CUENTA'),
                const SizedBox(height: 10),
                _panel([
                  _item(Icons.badge_rounded, 'DNI', perfil.dni.isEmpty ? '-' : perfil.dni),
                  _item(Icons.email_rounded, 'Correo', perfil.correo),
                  _item(Icons.cake_rounded, 'Fecha de nacimiento', perfil.fechaNacimientoCorta),
                  _item(Icons.event_available_rounded, 'Miembro desde',
                      perfil.fechaRegistroCorta,
                      esUltimo: true),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(UsuarioPerfil perfil) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _fondoPanel,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _azul,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              perfil.iniciales,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perfil.nombreCompleto,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.bold, color: _texto),
                ),
                const SizedBox(height: 3),
                Text(
                  perfil.correo,
                  style: const TextStyle(
                      color: _gris, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _azul),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: _azul),
                      SizedBox(width: 4),
                      Text(
                        'CUENTA VERIFICADA',
                        style: TextStyle(
                          color: _azul,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _gris,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _panel(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _fondoPanel,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: _texto)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _gris, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, String value, {bool esUltimo = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: esUltimo
            ? null
            : const Border(bottom: BorderSide(color: _borde, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _azul, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _gris, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: _texto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
