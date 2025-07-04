import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models_exports.dart';
import 'cuenta_service.dart';

class MovimientoService {
  final CollectionReference _movimientosCollection =
      FirebaseFirestore.instance.collection('movimientos');
  final CuentaService _cuentaService = CuentaService();

  Future<void> agregarMovimiento(Movimiento movimiento) async {
    try {
      final docRef = await _movimientosCollection.add({
        'tipo': movimiento.tipo,
        'categoria': movimiento.categoria,
        'monto': movimiento.monto,
        'nota': movimiento.nota,
        'cuentaId': movimiento.cuentaId,
        'createdAt': Timestamp.now(),
      });

      // Después de guardar, actualiza el saldo de la cuenta
      final cuentaSnap = await FirebaseFirestore.instance
          .collection('cuentas')
          .doc(movimiento.cuentaId)
          .get();

      if (!cuentaSnap.exists) return;

      final cuenta = Cuenta.fromMap(cuentaSnap.data() as Map<String, dynamic>, cuentaSnap.id);

      double nuevoSaldo = cuenta.saldo;
      if (movimiento.tipo.toLowerCase() == 'ingreso') {
        nuevoSaldo += movimiento.monto;
      } else {
        nuevoSaldo -= movimiento.monto;
      }

      await _cuentaService.actualizarSaldo(cuenta.id, nuevoSaldo);
    } catch (e) {
      print('Error al agregar movimiento: $e');
      rethrow;
    }
  }

  Future<List<Movimiento>> obtenerMovimientosPorCuenta(String cuentaId) async {
    try {
      final snapshot = await _movimientosCollection
          .where('cuentaId', isEqualTo: cuentaId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            try {
              return Movimiento.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              print('Error al parsear movimiento ${doc.id}: $e');
              print('Datos del documento: ${doc.data()}');
              return null;
            }
          })
          .where((movimiento) => movimiento != null)
          .cast<Movimiento>()
          .toList();
    } catch (e) {
      print('Error al obtener movimientos por cuenta: $e');
      return [];
    }
  }

  Stream<List<Movimiento>> streamTodosLosMovimientos() {
    return _movimientosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Firebase snapshot recibido con ${snapshot.docs.length} documentos');
          
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  print('Procesando documento ${doc.id}: $data');
                  return Movimiento.fromMap(data, doc.id);
                } catch (e) {
                  print('Error al parsear movimiento ${doc.id}: $e');
                  print('Datos del documento: ${doc.data()}');
                  return null;
                }
              })
              .where((movimiento) => movimiento != null)
              .cast<Movimiento>()
              .toList();
        })
        .handleError((error) {
          print('Error en el stream de movimientos: $error');
          return <Movimiento>[];
        });
  }
}