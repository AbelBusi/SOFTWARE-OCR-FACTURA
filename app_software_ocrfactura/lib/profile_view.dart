import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1565C0),
                    ),
                    child: const Icon(Icons.person_rounded, size: 55, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle),
                      child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Blas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
            ),
            const Text(
              'Ingeniería de Sistemas • UTP',
              style: TextStyle(color: Color(0xFF78909C), fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            _buildProfileItem(Icons.badge_rounded, 'Rol de Usuario', 'Administrador de Sistema'),
            _buildProfileItem(Icons.domain_rounded, 'Sede', 'Chiclayo'),
            _buildProfileItem(Icons.verified_user_rounded, 'Validación SUNAT', 'API Key Activa'),
            _buildProfileItem(Icons.security_rounded, 'Seguridad', 'Token JWT Firme'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF78909C), fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}