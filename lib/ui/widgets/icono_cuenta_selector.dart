import 'package:flutter/material.dart';

final List<Map<String, dynamic>> listaIconos = [
  {'icon': Icons.account_balance_wallet, 'nombre': 'wallet'},
  {'icon': Icons.credit_card, 'nombre': 'card'},
  {'icon': Icons.savings, 'nombre': 'bank'},
  {'icon': Icons.attach_money, 'nombre': 'money'},
];

class IconoCuentaSelector extends StatelessWidget {
  final String iconoSeleccionado;
  final ValueChanged<String> onChanged;

  const IconoCuentaSelector({
    super.key,
    required this.iconoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: listaIconos.map((iconMap) {
        final selected = iconoSeleccionado == iconMap['nombre'];
        return GestureDetector(
          onTap: () => onChanged(iconMap['nombre']),
          child: CircleAvatar(
            backgroundColor: selected ? Theme.of(context).primaryColor : Colors.grey[200],
            child: Icon(
              iconMap['icon'],
              color: selected ? Colors.white : Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }
}
