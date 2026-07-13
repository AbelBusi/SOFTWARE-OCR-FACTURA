import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'profile_view.dart';
import 'chat_page.dart';
import 'l10n/app_localizations.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  static const Color _azul = Color(0xFF1565C0);
  static const Color _texto = Color(0xFF263238);
  static const Color _gris = Color(0xFF78909C);
  static const Color _borde = Color(0xFFE0E0E0);
  static const Color _fondoActivo = Color(0xFFE3EEFB);

  final List<Widget> _views = [
    const DashboardView(),
    const HistoryView(),
    const ProfileView(),
  ];

  Future<bool> _mostrarDialogoConfirmacion({
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: _texto),
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 14, color: _gris, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: _gris),
            child: Text(context.tr('cancel'), style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC62828),
              side: const BorderSide(color: Color(0xFFC62828)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(textoConfirmar, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await _mostrarDialogoConfirmacion(
      titulo: context.tr('logout_title'),
      mensaje: context.tr('logout_msg'),
      textoConfirmar: context.tr('logout_confirm'),
    );
    if (confirmar && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _salirDeLaApp() async {
    final confirmar = await _mostrarDialogoConfirmacion(
      titulo: context.tr('exit_title'),
      mensaje: context.tr('exit_msg'),
      textoConfirmar: context.tr('exit_confirm'),
    );
    if (confirmar) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _salirDeLaApp();
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _views,
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildChatBubble(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _borde, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  _buildNavItem(icon: Icons.analytics_rounded, label: context.tr('nav_panel'), index: 0),
                  _buildNavItem(icon: Icons.history_toggle_off_rounded, label: context.tr('nav_history'), index: 1),
                  _buildScanItem(),
                  _buildNavItem(icon: Icons.person_outline_rounded, label: context.tr('nav_profile'), index: 2),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble() {
    return Material(
      color: _azul,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black45,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatPage()),
        ),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool activo = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: activo ? _fondoActivo : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: activo ? _azul : _gris, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: activo ? FontWeight.bold : FontWeight.w500,
                  color: activo ? _azul : _gris,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanItem() {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/camera'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _azul,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 3),
            Text(
              context.tr('nav_scan'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _texto),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Expanded(
      child: InkWell(
        onTap: _cerrarSesion,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: _gris, size: 22),
            const SizedBox(height: 2),
            Text(
              context.tr('nav_exit'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _gris),
            ),
          ],
        ),
      ),
    );
  }
}