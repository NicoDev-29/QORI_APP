import 'package:flutter/material.dart';
import 'package:qori/providers/presupuesto_provider.dart';
import 'package:qori/models/movimiento.dart';
import 'package:qori/themes/theme.dart';

class PresupuestoResumenWidget extends StatelessWidget {
  final PresupuestoProvider presupuestoProvider;
  final List<Movimiento> movimientosDelMes;
  const PresupuestoResumenWidget({
    Key? key,
    required this.presupuestoProvider,
    required this.movimientosDelMes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = presupuestoProvider.presupuestoTotal;
    final restante = presupuestoProvider.presupuestoTotalRestante(movimientosDelMes);
    final porcentaje = total > 0 ? (restante / total * 100).clamp(0, 100) : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Presupuesto mensual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('S/. ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text('Restante: S/. ${restante.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(0)}%)', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
