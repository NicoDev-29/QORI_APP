import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/models/models_exports.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/providers/cuenta_provider.dart';
import 'package:qori/services/movimiento_service.dart';
import 'screens_exports.dart';
import 'package:qori/ui/widgets/widgets_export.dart';

class CuentaDetalleScreen extends StatelessWidget {
  final Cuenta cuenta;
  const CuentaDetalleScreen({super.key, required this.cuenta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cuenta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar',
            onPressed: () async {
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarCuentaScreen(cuenta: cuenta),
                ),
              );
              if (actualizado == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cuenta actualizada correctamente.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Eliminar',
            onPressed: () => _confirmarEliminar(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Movimiento>>(
        future: MovimientoService().obtenerMovimientosPorCuenta(cuenta.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final movimientos = snapshot.data ?? [];
          double totalIngresos = 0;
          double totalEgresos = 0;
          for (final m in movimientos) {
            if (m.tipo.toLowerCase() == 'ingreso') {
              totalIngresos += m.monto;
            } else {
              totalEgresos += m.monto;
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Resumen visual de la cuenta
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryLight,
                                child: Icon(
                                  _getIconData(cuenta.icono),
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cuenta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    Text(_getTipoText(cuenta.tipo), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                    if (cuenta.nota != null && cuenta.nota!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text('Nota: ${cuenta.nota!}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'S/. ${cuenta.saldo.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: cuenta.tipo == 'Crédito' ? Colors.red : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    cuenta.tipo == 'Crédito' ? 'Pasivo' : 'Activo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cuenta.tipo == 'Crédito' ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Indicadores de ingresos y egresos
                      Row(
                        children: [
                          const Text('Movimientos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                              Text('S/. ${totalEgresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                              Text('S/. ${totalIngresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              movimientos.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No hay movimientos para esta cuenta.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, idx) {
                            // Agrupa por fecha si usas MovimientosAgrupadosPorFecha, si no, muestra lista simple:
                            return MovimientosAgrupadosPorFecha(movimientos: movimientos);
                          },
                          childCount: 1,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text('¿Estás seguro de eliminar esta cuenta? Esta acción no se puede deshacer. '
            'Los movimientos asociados seguirán existiendo.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Provider.of<CuentaProvider>(context, listen: false).eliminarCuenta(cuenta.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta eliminada exitosamente.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'money': return Icons.attach_money;
      case 'card': return Icons.credit_card;
      case 'bank': return Icons.account_balance;
      case 'wallet': return Icons.account_balance_wallet;
      default: return Icons.account_balance_wallet;
    }
  }
  String _getTipoText(String tipo) {
    switch (tipo) {
      case 'Ahorro': return 'Cuenta de ahorro';
      case 'Débito': return 'Tarjeta de débito';
      case 'Crédito': return 'Tarjeta de crédito';
      default: return tipo;
    }
  }
}
