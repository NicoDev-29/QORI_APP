import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models_exports.dart';

class CuentaService {
  final CollectionReference _cuentasCollection =
      FirebaseFirestore.instance.collection('cuentas');

  /// Agrega una cuenta nueva a Firestore
  Future<void> agregarCuenta(Cuenta cuenta) async {
    try {
      await _cuentasCollection.add(cuenta.toMap());
    } catch (e) {
      throw "Error al guardar cuenta: $e";
    }
  }

  /// Retorna un stream con todas las cuentas ordenadas por fecha de creación
  Stream<List<Cuenta>> obtenerCuentas() {
    return _cuentasCollection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cuenta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Actualiza el saldo de la cuenta
  Future<void> actualizarSaldo(String cuentaId, double nuevoSaldo) async {
    await _cuentasCollection.doc(cuentaId).update({'saldo': nuevoSaldo});
  }

  /// Actualiza todos los campos principales de la cuenta
  Future<void> actualizarCuenta(Cuenta cuenta) async {
    await _cuentasCollection.doc(cuenta.id).update({
      'nombre': cuenta.nombre,
      'saldo': cuenta.saldo,
      'tipo': cuenta.tipo,
      'icono': cuenta.icono,
      'nota': cuenta.nota,
      // El campo 'createdAt' no se actualiza para mantener el original
    });
  }

  /// Elimina la cuenta (pero no sus movimientos asociados)
  Future<void> eliminarCuenta(String cuentaId) async {
    await _cuentasCollection.doc(cuentaId).delete();
  }
}
