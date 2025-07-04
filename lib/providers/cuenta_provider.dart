import 'package:flutter/material.dart';
import '../models/models_exports.dart';
import '../services/services_export.dart';

class CuentaProvider extends ChangeNotifier {
  final CuentaService _servicio = CuentaService();
  List<Cuenta> _cuentas = [];
  bool _isLoading = false;

  List<Cuenta> get cuentas => _cuentas;
  bool get isLoading => _isLoading;

  CuentaProvider() {
    _cargarCuentas();
  }

  Future<void> _cargarCuentas() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _servicio.obtenerCuentas().listen((cuentas) {
        _cuentas = cuentas;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarCuenta(Cuenta cuenta) async {
    try {
      await _servicio.agregarCuenta(cuenta);
      // No llamamos notifyListeners aquí, el stream ya actualizará
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizarCuenta(Cuenta cuenta) async {
  await _servicio.actualizarCuenta(cuenta);
  
  }


  Future<void> eliminarCuenta(String cuentaId) async {
    await _servicio.eliminarCuenta(cuentaId);
    notifyListeners();
  }

  double get totalActivos {
    return _cuentas.where((c) => c.tipo != 'Crédito').fold(0, (sum, cuenta) => sum + cuenta.saldo);
  }

  double get totalPasivos {
    return _cuentas.where((c) => c.tipo == 'Crédito').fold(0, (sum, cuenta) => sum + cuenta.saldo);
  }

  double get patrimonioNeto => totalActivos - totalPasivos;
}
