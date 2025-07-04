import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/models/models_exports.dart';
import 'package:qori/providers/providers_export.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/ui/widgets/movimiento_item.dart';
import 'package:qori/ui/utils/fecha_utils.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
  }

  bool esMismoDia(DateTime a, DateTime b) {
    // Normalizar ambas fechas a medianoche para comparar solo año, mes y día
    final fechaA = DateTime(a.year, a.month, a.day);
    final fechaB = DateTime(b.year, b.month, b.day);
    return fechaA.isAtSameMomentAs(fechaB);
  }

  @override
  Widget build(BuildContext context) {
    final movProvider = Provider.of<MovimientoProvider>(context);
    final cuentaProvider = Provider.of<CuentaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Movimientos"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                helpText: 'Filtrar por día',
                initialDate: _fechaSeleccionada ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _fechaSeleccionada = picked);
              }
            },
            tooltip: 'Selecciona día',
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() => _fechaSeleccionada = null);
            },
            tooltip: 'Quitar filtro',
          ),
        ],
      ),
      body: StreamBuilder<List<Movimiento>>(
        stream: movProvider.streamTodosLosMovimientos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final movimientos = snapshot.data ?? [];
          
          print('======= DEBUG Movimientos recibidos: ${movimientos.length}');
          for (var m in movimientos) {
            print('   - ${m.categoria} | Fecha: ${m.fecha} | ${m.fecha.toLocal()} | createdAt: ${m.createdAt}');
          }

          // Filtrar por fecha si hay una seleccionada
          final visibles = _fechaSeleccionada == null
              ? movimientos
              : movimientos.where((m) {
                  final fechaMovimiento = m.fecha; // Ya es DateTime local
                  print('Comparando: ${fechaMovimiento} con ${_fechaSeleccionada}');
                  return esMismoDia(fechaMovimiento, _fechaSeleccionada!);
                }).toList();

          print('======= DEBUG Movimientos visibles después del filtro: ${visibles.length}');

          if (visibles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _fechaSeleccionada == null 
                        ? 'No hay movimientos registrados.'
                        : 'No hay movimientos para el día seleccionado.',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  if (_fechaSeleccionada != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Fecha: ${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          }

          final agrupados = agruparMovimientosPorDia(visibles);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            itemCount: agrupados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final fecha = agrupados.keys.elementAt(index);
              final lista = agrupados[fecha]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 7, horizontal: 12),
                    child: Text(
                      fecha,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFE0E0E0),
                      indent: 76,
                      endIndent: 8,
                    ),
                    itemBuilder: (context, idx) {
                      final mov = lista[idx];
                      Cuenta? cuenta;
                      try {
                        cuenta = cuentaProvider.cuentas.firstWhere(
                          (c) => c.id == mov.cuentaId,
                        );
                      } catch (_) {
                        cuenta = null;
                      }
                      return MovimientoItem(movimiento: mov, cuenta: cuenta);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}