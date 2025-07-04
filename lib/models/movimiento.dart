import 'package:cloud_firestore/cloud_firestore.dart';

class Movimiento {
  final String id;
  final String tipo;
  final String categoria;
  final double monto;
  final String? nota;
  final String cuentaId;
  final Timestamp createdAt;

  Movimiento({
    required this.id,
    required this.tipo,
    required this.categoria,
    required this.monto,
    this.nota,
    required this.cuentaId,
    required this.createdAt,
  });

  factory Movimiento.fromMap(Map<String, dynamic> map, String documentId) {
    return Movimiento(
      id: documentId,
      tipo: map['tipo']?.toString() ?? 'gasto', // Valor por defecto
      categoria: map['categoria']?.toString() ?? 'Sin categoría', // Valor por defecto
      monto: _parseDouble(map['monto']),
      nota: map['nota']?.toString(), // Puede ser null
      cuentaId: map['cuentaId']?.toString() ?? '', // Valor por defecto
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(), // Valor por defecto
    );
  }

  // Método auxiliar para parsear double de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'categoria': categoria,
      'monto': monto,
      'nota': nota,
      'cuentaId': cuentaId,
      'createdAt': createdAt,
    };
  }

  DateTime get fecha => createdAt.toDate();
}