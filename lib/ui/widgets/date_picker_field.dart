import 'package:flutter/material.dart';
import 'package:qori/themes/theme.dart';
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final text = selectedDate == null
        ? ''
        : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';

    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        hintText: '',
        filled: true,
        fillColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? AppColors.secondary : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Required' : null,
    );
  }
}
