import 'package:flutter/material.dart';

class TipoCuentaSelector extends StatelessWidget {
  final String tipoSeleccionado;
  final ValueChanged<String> onChanged;

  const TipoCuentaSelector({
    super.key,
    required this.tipoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tipos = ['Ahorro', 'Débito', 'Crédito'];
    final colores = [
      Colors.green,
      Colors.blue,
      Colors.deepOrange,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(tipos.length, (i) {
        final selected = tipoSeleccionado == tipos[i];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => onChanged(tipos[i]),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? colores[i].withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? colores[i] : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    tipos[i],
                    style: TextStyle(
                      color: selected ? colores[i] : Colors.black87,
                      fontWeight: FontWeight.w600,
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
