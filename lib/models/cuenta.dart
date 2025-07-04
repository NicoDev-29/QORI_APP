import 'package:cloud_firestore/cloud_firestore.dart';

class Cuenta {
  final String id;
  final String nombre;
  final double saldo;
  final String tipo; // 'ahorro', 'debito', 'credito'
  final String icono; // nombre del icono
  final String? nota;
  final Timestamp createdAt;

  Cuenta({
    required this.id,
    required this.nombre,
    required this.saldo,
    required this.tipo,
    required this.icono,
    this.nota,
    required this.createdAt,
  });

  factory Cuenta.fromMap(Map<String, dynamic> map, String documentId) {
    return Cuenta(
      id: documentId,
      nombre: map['nombre'],
      saldo: map['saldo'].toDouble(),
      tipo: map['tipo'],
      icono: map['icono'],
      nota: map['nota'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'saldo': saldo,
      'tipo': tipo,
      'icono': icono,
      'nota': nota,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
