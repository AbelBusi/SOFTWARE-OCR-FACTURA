import 'package:flutter/material.dart';

class AppState {
  static final ValueNotifier<List<Map<String, String>>> facturas = ValueNotifier([
    {'ruc': '20601234567', 'empresa': 'Inversiones CIX S.A.C.', 'monto': 'S/ 1,250.00', 'estado': 'Aceptado', 'fecha': '25/05/2026'},
    {'ruc': '20459876543', 'empresa': 'Distribuidora del Norte', 'monto': 'S/ 420.50', 'estado': 'Alerta: Sin XML', 'fecha': '24/05/2026'},
    {'ruc': '20104857692', 'empresa': 'Logística Trujillana S.A.', 'monto': 'S/ 2,800.00', 'estado': 'Aceptado', 'fecha': '22/05/2026'},
  ]);
}