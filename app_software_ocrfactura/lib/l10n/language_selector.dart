import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'locale_controller.dart';

class LanguageSelector {
  LanguageSelector._();

  static Future<void> mostrar(BuildContext context) async {
    final actual = Localizations.localeOf(context).languageCode;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ctx.tr('language'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
            ),
            ...AppLocalizations.idiomas.entries.map((e) {
              final activo = e.key == actual;
              return ListTile(
                leading: Icon(
                  activo
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: activo ? const Color(0xFF1565C0) : const Color(0xFF78909C),
                ),
                title: Text(e.value),
                onTap: () async {
                  await cambiarIdioma(e.key);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
