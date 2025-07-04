import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 255, 175, 1); // Ámbar cálido
  static const Color primaryLight = Color(0xFFFFE082); // Ámbar claro o dorado suave
  static const Color secondary = Color.fromARGB(255, 254, 255, 255); // Azul petróleo para contraste y seriedad
  static const Color backgroundLight = Color(0xFFF5F5F5); // Blanco roto para fondo claro
  static const Color backgroundLight2 = Color.fromARGB(122, 245, 245, 245); // Blanco roto translúcido
  static const Color backgroundDark = Color(0xFF121212); // Negro profundo para dark mode
  static const Color textPrimary = Color(0xFF212121); // Texto oscuro
  static const Color textSecondary = Color(0xFF757575); // Texto gris
  static const Color error = Color(0xFFD32F2F); // Rojo para errores
  static const Color border = Color(0xFFBDBDBD); // Gris claro para bordes
}


class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.secondary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.secondary),
      titleTextStyle: TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      elevation: 4,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: const StadiumBorder(),
        elevation: 2,
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      hintStyle: TextStyle(color: AppColors.textSecondary),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      iconTheme: IconThemeData(color: AppColors.secondary),
      titleTextStyle: TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      elevation: 4,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        shape: const StadiumBorder(),
        elevation: 2,
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.secondary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      hintStyle: TextStyle(color: AppColors.textSecondary),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.secondary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
