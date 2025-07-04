import 'package:flutter/material.dart';
import 'package:qori/themes/theme.dart';
class CategoriaSelector extends StatelessWidget {
  final List<Map<String, dynamic>> categorias;
  final String? seleccionada;
  final ValueChanged<String> onChanged;

  const CategoriaSelector({
    Key? key,
    required this.categorias,
    required this.seleccionada,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.map((cat) {
        final selected = seleccionada == cat['label'];
        final colorFondo = selected ? AppColors.primary : AppColors.backgroundLight;
        final colorIcono = selected ? Colors.white : AppColors.primary;
        final colorTexto = selected ? Colors.white : (isDarkMode ? Colors.white70 : AppColors.textPrimary);

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(cat['icon'], size: 18, color: colorIcono),
              const SizedBox(width: 4),
              Text(cat['label'], style: TextStyle(color: colorTexto)),
            ],
          ),
          selected: selected,
          selectedColor: AppColors.primary,
          backgroundColor: colorFondo,
          labelStyle: TextStyle(
            color: colorTexto,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? Colors.transparent : AppColors.border,
              width: 1,
            ),
          ),
          elevation: selected ? 1 : 0,
          onSelected: (_) => onChanged(cat['label']),
        );
      }).toList(),
    );
  }
}
