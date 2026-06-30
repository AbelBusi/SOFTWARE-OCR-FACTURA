import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class CustomAlert {
  CustomAlert._();

  static void show(
      BuildContext context, {
        required String message,
        AlertType type = AlertType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    final config = _configFor(type);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(config.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
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
        return _AlertVisuals(Icons.check, const Color(0xFF1B5E20));
      case AlertType.error:
        return _AlertVisuals(Icons.error_outline, const Color(0xFFB71C1C));
      case AlertType.warning:
        return _AlertVisuals(Icons.warning_amber_rounded, const Color(0xFFE65100));
      case AlertType.info:
        return _AlertVisuals(Icons.info_outline, const Color(0xFF0D47A1));
    }
  }
}

class _AlertVisuals {
  final IconData icon;
  final Color color;
  const _AlertVisuals(this.icon, this.color);
}