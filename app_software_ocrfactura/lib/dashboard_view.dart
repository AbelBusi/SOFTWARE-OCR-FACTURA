import 'package:flutter/material.dart';
import 'app_state.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Facturas', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppState.facturas,
        builder: (context, lista, child) {
          double total = lista.fold(0, (sum, item) {
            String montoClean = item['monto']!.replaceAll('S/ ', '').replaceAll(',', '');
            return sum + double.parse(montoClean);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: const Color(0xFF0D6B68).withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF0D6B68), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Procesado (Mes)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Icon(Icons.trending_up_rounded, size: 40, color: Color(0xFF0D6B68)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Estadísticas de los Últimos Días', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('Lun', 0.4),
                      _buildBar('Mar', 0.7),
                      _buildBar('Mié', 0.5),
                      _buildBar('Jue', 0.9),
                      _buildBar('Vie', 0.3),
                      _buildBar('Sáb', 0.6),
                      _buildBar('Dom', 0.2),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Alertas y Validaciones Críticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...lista.where((item) => item['estado']!.contains('Alerta')).map((item) {
                  return Card(
                    color: Colors.white.withOpacity(0.01),
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.redAccent, width: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      title: Text(item['empresa']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('RUC: ${item['ruc']} • ${item['estado']}', style: const TextStyle(fontSize: 12)),
                      trailing: Text(item['monto']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBar(String dia, double porcentaje) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF0D6B68).withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100 * porcentaje,
              width: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF0D6B68),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(dia, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }
}