import 'package:flutter/material.dart';
import 'package:qori/themes/theme.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado con avatar y nombre
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 48, bottom: 28),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: width * 0.15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.primary, size: width * 0.18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Regina Pérez',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'regina@email.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Botón "Cámbiate a Premium"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              label: const Text(
                'Cámbiate a Premium',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              onPressed: () {
                // Acción futura: mostrar modal o ir a pantalla premium
              },
            ),
          ),

          // Información básica del usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 18),
                _infoTile(icon: Icons.email, label: 'Correo', value: 'regina@email.com'),
                const SizedBox(height: 10),
                _infoTile(icon: Icons.cake, label: 'Cumpleaños', value: '12 de julio'),
                const SizedBox(height: 10),
                _infoTile(icon: Icons.phone, label: 'Teléfono', value: '+51 999 888 777'),
                const SizedBox(height: 10),
                _infoTile(icon: Icons.location_on, label: 'Ciudad', value: 'Lima, Perú'),
              ],
            ),
          ),

          // Botón "Cerrar sesión"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 24),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.redAccent,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
              onPressed: () {
                // Aquí irá la lógica real de logout cuando implementes autenticación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cerrar sesión (maquetado)')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.black54, fontSize: 15)),
        ],
      ),
    );
  }
}
