import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/providers/presupuesto_provider.dart';
import 'package:qori/models/presupuesto.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/constants/categoria_constants.dart';
import 'package:qori/providers/movimiento_provider.dart';
import 'package:qori/models/models_exports.dart';

class PresupuestoScreen extends StatelessWidget {
  const PresupuestoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PresupuestoProvider>(context, listen: false);
    final movimientoProvider = Provider.of<MovimientoProvider>(context, listen: false);

    final hoy = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos Mensuales'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<List<Presupuesto>>(
        stream: provider.presupuestosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return StreamBuilder<List<Movimiento>>(
            stream: movimientoProvider.streamTodosLosMovimientos(),
            builder: (context, movSnapshot) {
              final movimientos = movSnapshot.data ?? [];
              final movimientosDelMes = movimientos.where((m) =>
                m.fecha.year == hoy.year && m.fecha.month == hoy.month
              ).toList();

              if (data.isEmpty) {
                return const Center(child: Text('No hay presupuestos aún.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, i) {
                  final p = data[i];
                  final restante = provider.presupuestoCategoriaRestante(
                    categoria: p.categoria,
                    movimientosDelMes: movimientosDelMes,
                  );
                  final porcentaje = p.monto > 0 ? (restante / p.monto * 100).clamp(0, 100) : 0;

                  return ListTile(
                    leading: Icon(
                      CategoriasConstants.iconoPorCategoria(p.categoria),
                      color: AppColors.primary,
                    ),
                    title: Text(p.categoria),
                    subtitle: Text(
                      'Presupuesto mensual: S/. ${p.monto.toStringAsFixed(2)}\n'
                      'Restante: S/. ${restante.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(0)}%)',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed:
                              () => _mostrarDialogEditar(context, provider, p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (c) => AlertDialog(
                                    title: const Text("¿Eliminar presupuesto?"),
                                    content: Text(
                                      "¿Seguro de borrar el presupuesto de \"${p.categoria}\"?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text(
                                          "Eliminar",
                                          style: TextStyle(color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await provider.eliminarPresupuesto(p.id);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogAgregar(context, provider),
      ),
    );
  }

  void _mostrarDialogEditar(
    BuildContext context,
    PresupuestoProvider provider,
    Presupuesto p,
  ) {
    final controller = TextEditingController(text: p.monto.toStringAsFixed(2));
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar "${p.categoria}"'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto mensual (S/.)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nuevoMonto =
                      double.tryParse(controller.text) ?? p.monto;
                  final actualizado = Presupuesto(
                    id: p.id,
                    categoria: p.categoria,
                    monto: nuevoMonto,
                    periodo: p.periodo,
                    createdAt: p.createdAt,
                  );
                  await provider.actualizarPresupuesto(actualizado);
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _mostrarDialogAgregar(
  BuildContext context,
  PresupuestoProvider provider,
) {
  String? categoriaSeleccionada;
  double monto = 0.0;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Agregar presupuesto'),
      content: Form(
        key: formKey,
        child: StatefulBuilder(
          builder: (context, setModalState) => SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Categoría"),
                  items: CategoriasConstants.categoriasGastos
                      .map(
                        (cat) => DropdownMenuItem<String>(
                          value: cat['label'] as String,
                          child: Row(
                            children: [
                              Icon(cat['icon'] as IconData, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Text(cat['label'] as String),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  value: categoriaSeleccionada,
                  onChanged: (val) => setModalState(() => categoriaSeleccionada = val),
                  validator: (val) => val == null ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto mensual (S/.)',
                  ),
                  onChanged: (val) => setModalState(() => monto = double.tryParse(val) ?? 0.0),
                  validator: (val) {
                    final d = double.tryParse(val ?? '');
                    if (d == null || d <= 0) return 'Ingresa un monto válido';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            final nuevo = Presupuesto(
              id: '',
              categoria: categoriaSeleccionada!,
              monto: monto,
              periodo: 'mensual',
              createdAt: Timestamp.now(),
            );
            await provider.agregarPresupuesto(nuevo);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    ),
  );
}
}
