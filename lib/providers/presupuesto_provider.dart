import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/presupuesto.dart';
import '../services/presupuesto_service.dart';
import '../models/movimiento.dart';

class PresupuestoProvider extends ChangeNotifier {
  final PresupuestoService _service = PresupuestoService();

  List<Presupuesto> _presupuestos = [];
  List<Presupuesto> get presupuestos => _presupuestos;

  Stream<List<Presupuesto>> get presupuestosStream => _service.streamPresupuestos();

  Future<void> cargarPresupuestos() async {
    _presupuestos = await _service.fetchPresupuestosOnce();
    notifyListeners();
  }

  Future<void> agregarPresupuesto(Presupuesto p) async {
    await _service.agregarPresupuesto(p);
    await cargarPresupuestos();
  }

  Future<void> actualizarPresupuesto(Presupuesto p) async {
    await _service.actualizarPresupuesto(p);
    await cargarPresupuestos();
  }

  Future<void> eliminarPresupuesto(String id) async {
    await _service.eliminarPresupuesto(id);
    await cargarPresupuestos();
  }

  double presupuestoCategoriaRestante({
    required String categoria,
    required List<Movimiento> movimientosDelMes,
  }) {
    final p = _presupuestos.firstWhere(
      (x) => x.categoria == categoria,
      orElse: () => Presupuesto(
        id: '',
        categoria: categoria,
        monto: 0,
        periodo: 'mensual',
        createdAt: Timestamp.now(),
      ),
    );
    final gastos = movimientosDelMes
        .where((m) =>
            m.categoria == categoria &&
            m.tipo.toLowerCase() == 'gasto')
        .fold(0.0, (sum, m) => sum + m.monto);

    return (p.monto - gastos).clamp(0, p.monto);
  }

  double get presupuestoTotal => _presupuestos.fold(0, (a, b) => a + b.monto);

  double presupuestoTotalRestante(List<Movimiento> movimientosDelMes) {
    double restante = 0.0;
    for (final p in _presupuestos) {
      final gastos = movimientosDelMes
          .where((m) => m.categoria == p.categoria && m.tipo.toLowerCase() == 'gasto')
          .fold(0.0, (sum, m) => sum + m.monto);
      restante += (p.monto - gastos).clamp(0, p.monto);
    }
    return restante;
  }

  double presupuestoTotalRestanteConLista(
    List<Movimiento> movimientosDelMes,
    List<Presupuesto> presupuestos,
  ) {
    double restante = 0.0;
    for (final p in presupuestos) {
      final gastos = movimientosDelMes
          .where((m) => m.categoria == p.categoria && m.tipo.toLowerCase() == 'gasto')
          .fold(0.0, (sum, m) => sum + m.monto);
      restante += (p.monto - gastos).clamp(0, p.monto);
    }
    return restante;
  }
}
