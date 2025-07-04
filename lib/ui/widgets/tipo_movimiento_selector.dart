import 'package:flutter/material.dart';
import 'package:qori/constants/categoria_constants.dart';

class TipoMovimientoSelector extends StatelessWidget {
  final String tipoSeleccionado;
  final ValueChanged<String> onChanged;

  const TipoMovimientoSelector({
    Key? key,
    required this.tipoSeleccionado,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tipos = [TipoMovimiento.ingreso, TipoMovimiento.gasto];
    final etiquetas = ['Ingreso', 'Gasto'];
    
    // Colores para los tipos
    final colores = [
      const Color(0xFF4CAF50), // Verde para ingresos
      const Color(0xFFF44336), // Rojo para gastos
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(tipos.length, (i) {
        final selected = tipoSeleccionado == tipos[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onChanged(tipos[i]),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? colores[i] : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? colores[i] : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    etiquetas[i],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
