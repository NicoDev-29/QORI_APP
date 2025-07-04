import 'package:flutter/material.dart';
import 'package:qori/themes/theme.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // Propiedad validator añadida

  const InputField({
    Key? key,
    required this.controller,
    this.hintText,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator, // Parámetro opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.backgroundLight2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator, // Se asigna el validador
    );
  }
}
