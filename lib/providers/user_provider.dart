// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

class UsuarioModel {
  final String nombre;
  UsuarioModel({required this.nombre});
}

class UserProvider extends ChangeNotifier {
  UsuarioModel usuario = UsuarioModel(nombre: "Regina Pérez");

  // Puedes expandirlo si implementas login después
}
