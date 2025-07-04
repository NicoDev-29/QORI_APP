import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presupuesto.dart';

class PresupuestoService {
  final CollectionReference _col = FirebaseFirestore.instance.collection('presupuestos');

  Future<void> agregarPresupuesto(Presupuesto p) async {
    await _col.add(p.toMap());
  }

  Future<void> actualizarPresupuesto(Presupuesto p) async {
    await _col.doc(p.id).update(p.toMap());
  }

  Future<void> eliminarPresupuesto(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Presupuesto>> streamPresupuestos() => _col
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => Presupuesto.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());

  Future<List<Presupuesto>> fetchPresupuestosOnce() async {
    final snap = await _col.get();
    return snap.docs
        .map((doc) => Presupuesto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
