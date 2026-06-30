import 'package:flutter/material.dart';

/// Tipos de alerta disponibles.
enum AlertType { success, error, warning, info }

/// Sistema de alertas propio para reemplazar los SnackBar genéricos.
///
/// Soluciona el bug de encolamiento de Flutter: por defecto, si se llama
/// a showSnackBar() varias veces seguidas, cada alerta nueva espera a que
/// la anterior complete su animación de salida antes de mostrarse, lo que
/// da la sensación de que las alertas "se quedan pegadas" o tardan en
/// desaparecer. Aquí se limpia instantáneamente cualquier alerta anterior
/// (sin esperar su animación) antes de mostrar la nueva.
class CustomAlert {
  CustomAlert._();

  static void show(
      BuildContext context, {
        required String message,
        AlertType type = AlertType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    final messenger = ScaffoldMessenger.of(context);

    // Clave del fix: clearSnackBars() elimina TODA la cola de alertas
    // de forma instantánea (sin animación), a diferencia de
    // hideCurrentSnackBar() que anima la salida y genera el retraso.
    messenger.clearSnackBars();

    final config = _configFor(type);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(config.icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: config.color.withOpacity(0.4), width: 1),
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: AlertType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: AlertType.error, duration: const Duration(seconds: 4));

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: AlertType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: AlertType.info);

  static _AlertVisuals _configFor(AlertType type) {
    switch (type) {
      case AlertType.success:
        return _AlertVisuals(Icons.check_circle_rounded, const Color(0xFF2E7D32));
      case AlertType.error:
        return _AlertVisuals(Icons.error_rounded, const Color(0xFFC62828));
      case AlertType.warning:
        return _AlertVisuals(Icons.warning_rounded, const Color(0xFFEF6C00));
      case AlertType.info:
        return _AlertVisuals(Icons.info_rounded, const Color(0xFF1565C0));
    }
  }
}

class _AlertVisuals {
  final IconData icon;
  final Color color;
  const _AlertVisuals(this.icon, this.color);
}