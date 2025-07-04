import 'package:cloud_firestore/cloud_firestore.dart';

class Presupuesto {
  final String id;
  final String categoria;
  final double monto;
  final String periodo; 
  final Timestamp createdAt;

  Presupuesto({
    required this.id,
    required this.categoria,
    required this.monto,
    required this.periodo,
    required this.createdAt,
  });

  factory Presupuesto.fromMap(Map<String, dynamic> map, String id) {
    return Presupuesto(
      id: id,
      categoria: map['categoria'],
      monto: (map['monto'] as num).toDouble(),
      periodo: map['periodo'] ?? 'mensual',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'monto': monto,
      'periodo': periodo,
      'createdAt': createdAt,
    };
  }
}
