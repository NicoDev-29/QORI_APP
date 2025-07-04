import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../services/movimiento_service.dart';

class MovimientoProvider extends ChangeNotifier {
  final MovimientoService _movimientoService = MovimientoService();

  Future<void> agregarMovimiento(Movimiento movimiento) async {
    await _movimientoService.agregarMovimiento(movimiento);
    notifyListeners();
  }

  Future<List<Movimiento>> obtenerMovimientosPorCuenta(String cuentaId) async {
    return await _movimientoService.obtenerMovimientosPorCuenta(cuentaId);
  }

  Stream<List<Movimiento>> streamTodosLosMovimientos() {
  return _movimientoService.streamTodosLosMovimientos();
}

}
