import 'package:flutter/material.dart';

class TipoMovimiento {
  static const String ingreso = 'Ingreso';
  static const String gasto = 'Gasto';
}

class CategoriasConstants {
  // Categorías para INGRESOS
  static const List<Map<String, dynamic>> categoriasIngresos = [
    {'icon': Icons.work, 'label': 'Salario', 'color': 0xFFFFA726},
    {'icon': Icons.family_restroom, 'label': 'Familia', 'color': 0xFF42A5F5},
    {'icon': Icons.trending_up, 'label': 'Inversión', 'color': 0xFF66BB6A},
    {'icon': Icons.card_giftcard, 'label': 'Bono', 'color': 0xFFFFCA28},
    {'icon': Icons.account_balance, 'label': 'Dividendo', 'color': 0xFF26C6DA},
    {'icon': Icons.monetization_on, 'label': 'Préstamo', 'color': 0xFF5C6BC0},
    {'icon': Icons.redeem, 'label': 'Regalo', 'color': 0xFFEC407A},
    {'icon': Icons.emoji_events, 'label': 'Premio', 'color': 0xFFFFD54F},
    {'icon': Icons.category, 'label': 'Otro ingreso', 'color': 0xFF9E9E9E},
  ];

  // Categorías para GASTOS
  static const List<Map<String, dynamic>> categoriasGastos = [
    {'icon': Icons.restaurant, 'label': 'Comida', 'color': 0xFFFF7043},
    {'icon': Icons.directions_bus, 'label': 'Transporte', 'color': 0xFF42A5F5},
    {'icon': Icons.celebration, 'label': 'Ocio', 'color': 0xFFAB47BC},
    {'icon': Icons.local_hospital, 'label': 'Salud', 'color': 0xFF66BB6A},
    {'icon': Icons.school, 'label': 'Educación', 'color': 0xFF5C6BC0},
    {'icon': Icons.shopping_bag, 'label': 'Compras', 'color': 0xFFEC407A},
    {'icon': Icons.home, 'label': 'Hogar', 'color': 0xFF8D6E63},
    {'icon': Icons.directions_car, 'label': 'Vehículo', 'color': 0xFF78909C},
    {'icon': Icons.phone, 'label': 'Servicios', 'color': 0xFF26C6DA},
    {'icon': Icons.category, 'label': 'Otro gasto', 'color': 0xFF9E9E9E},
  ];

  // Método para obtener categorías según el tipo
  static List<Map<String, dynamic>> getCategoriasPorTipo(String tipo) {
    switch (tipo) {
      case TipoMovimiento.ingreso:
        return categoriasIngresos;
      case TipoMovimiento.gasto:
        return categoriasGastos;
      default:
        return categoriasGastos;
    }
  }

  static IconData iconoPorCategoria(String label) {
    final all = [...categoriasIngresos, ...categoriasGastos];
    final item = all.firstWhere(
      (cat) => cat['label'] == label,
      orElse: () => {'icon': Icons.category},
    );
    return item['icon'] as IconData;
  }

  /// Devuelve el color para una categoría por su nombre
  static Color colorPorCategoria(String label) {
    final all = [...categoriasIngresos, ...categoriasGastos];
    final item = all.firstWhere(
      (cat) => cat['label'] == label,
      orElse: () => {'color': 0xFF9E9E9E},
    );
    return Color(item['color'] as int);
  }
}
