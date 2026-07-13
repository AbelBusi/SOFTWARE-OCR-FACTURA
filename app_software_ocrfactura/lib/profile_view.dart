import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const Color _azul = Color(0xFF1565C0);
  static const Color _texto = Color(0xFF263238);
  static const Color _gris = Color(0xFF78909C);
  static const Color _borde = Color(0xFFE0E0E0);
  static const Color _fondoPanel = Color(0xFFFAFAFA);
  static const Color _ambar = Color(0xFFB26A00);
  static const Color _fondoAmbar = Color(0xFFFFF3E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Encabezado de usuario ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _fondoPanel,
                border: Border.all(color: _borde),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _azul,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.person_rounded, size: 38, color: Colors.white),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _azul, width: 1.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(Icons.edit_rounded, size: 14, color: _azul),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cesar Abel',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _texto),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Ingeniería de Sistemas • UTP',
                          style: TextStyle(color: _gris, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _azul),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'CUENTA VERIFICADA',
                            style: TextStyle(
                              color: _azul,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Estadísticas rápidas ---
            Row(
              children: [
                Expanded(child: _buildStat('escaneados', '0')),
                const SizedBox(width: 12),
                Expanded(child: _buildStat('Sesiones activas', '1')),
                const SizedBox(width: 12),
                Expanded(child: _buildStat('Última act.', 'Hoy')),
              ],
            ),

            const SizedBox(height: 28),

            // --- Información de cuenta ---
            _buildSectionHeader('INFORMACIÓN DE CUENTA'),
            const SizedBox(height: 10),
            _buildPanel([
              _buildProfileItem(Icons.badge_rounded, 'Rol de Usuario', 'Administrador de Sistema'),
              _buildProfileItem(Icons.domain_rounded, 'Sede', 'Chiclayo'),
              _buildProfileItem(Icons.verified_user_rounded, 'Validación SUNAT', 'API Key Activa'),
              _buildProfileItem(Icons.security_rounded, 'Seguridad', 'Token JWT Firme'),
            ]),

            const SizedBox(height: 28),

            // --- Preferencias ---
            _buildSectionHeader('PREFERENCIAS'),
            const SizedBox(height: 10),
            _buildPanel([
              _buildToggleItem(Icons.notifications_rounded, 'Notificaciones push', true),
              _buildToggleItem(Icons.fingerprint_rounded, 'Desbloqueo biométrico', false),
              _buildLinkItem(context, Icons.language_rounded, 'Idioma', 'Español'),
            ]),

            const SizedBox(height: 28),

            // --- Próximamente / en desarrollo ---
            _buildSectionHeader('PRÓXIMAMENTE'),
            const SizedBox(height: 10),
            _buildPanel([
              _buildComingSoonItem(context, Icons.history_rounded, 'Historial de actividad'),
              _buildComingSoonItem(context, Icons.cloud_upload_rounded, 'Respaldo en la nube'),
              _buildComingSoonItem(context, Icons.face_retouching_natural_rounded, 'Verificación facial'),
              _buildComingSoonItem(context, Icons.family_restroom_rounded, 'Perfiles vinculados'),
            ]),

            const SizedBox(height: 28),

            // --- Acciones ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _azul,
                      side: const BorderSide(color: _azul),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers ----------

  Widget _buildSectionHeader(String title) {
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

  Widget _buildPanel(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _fondoPanel,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _texto)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _gris, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _borde, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _azul, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _gris, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _texto),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool valorInicial) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool activo = valorInicial;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _borde, width: 1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _azul, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _texto)),
              ),
              Switch(
                value: activo,
                activeColor: _azul,
                onChanged: (val) => setState(() => activo = val),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinkItem(BuildContext context, IconData icon, String title, String value) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: _azul, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _texto)),
            ),
            Text(value, style: const TextStyle(color: _gris, fontSize: 13)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: _gris, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title está en desarrollo', style: const TextStyle(fontWeight: FontWeight.w500)),
            backgroundColor: _texto,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        );
      },
      child: Opacity(
        opacity: 0.55,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _borde, width: 1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _gris, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _texto)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _fondoAmbar,
                  border: Border.all(color: _ambar),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'EN DESARROLLO',
                  style: TextStyle(
                    color: _ambar,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}