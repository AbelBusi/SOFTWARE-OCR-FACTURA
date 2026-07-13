import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleKey = 'idioma_app';

final ValueNotifier<Locale> localeController = ValueNotifier<Locale>(
  const Locale('es'),
);

Future<void> cargarIdioma() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_kLocaleKey);
  if (code != null && ['es', 'en', 'pt'].contains(code)) {
    localeController.value = Locale(code);
  }
}

Future<void> cambiarIdioma(String code) async {
  if (!['es', 'en', 'pt'].contains(code)) return;
  localeController.value = Locale(code);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLocaleKey, code);
}
