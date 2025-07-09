import 'package:flutter/material.dart';
import 'package:qori/models/movimiento.dart';
import 'package:qori/models/cuenta.dart';
import 'package:qori/constants/categoria_constants.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/ui/utils/fecha_utils.dart';

class MovimientoItem extends StatelessWidget {
  final Movimiento movimiento;
  final Cuenta? cuenta;
  const MovimientoItem({super.key, required this.movimiento, this.cuenta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 8, top: 1, bottom: 1),
      child: ListTile(
        tileColor: Colors.white,
        minVerticalPadding: 14,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: CategoriasConstants.colorPorCategoria(movimiento.categoria).withOpacity(0.13),
          child: Icon(
            CategoriasConstants.iconoPorCategoria(movimiento.categoria),
            color: movimiento.tipo == TipoMovimiento.ingreso ? Colors.green : Colors.red,
            size: 26,
          ),
        ),
        title: Text(
          movimiento.categoria,
          style: TextStyle(
            color: movimiento.tipo == TipoMovimiento.ingreso ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600, fontSize: 16,
          ),
        ),
        subtitle: cuenta != null
            ? Row(
                children: [
                  Icon(_iconoCuenta(cuenta!.icono), size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    cuenta!.nombre,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  // Descripción con límite de ancho y salto de línea
                  Expanded(
                    child: Text(
                      movimiento.nota ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Puedes ajustar el número de líneas
                    ),
                  ),
                ],
              )
            : (movimiento.nota != null && movimiento.nota!.isNotEmpty)
                ? Text(
                    movimiento.nota!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Ajusta según prefieras
                  )
                : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${movimiento.tipo == TipoMovimiento.ingreso ? '+' : '-'}S/. ${movimiento.monto.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: movimiento.tipo == TipoMovimiento.ingreso ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              horaBonita(movimiento.fecha),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }

  IconData _iconoCuenta(String iconName) {
    switch (iconName) {
      case 'money': return Icons.attach_money;
      case 'card': return Icons.credit_card;
      case 'bank': return Icons.account_balance;
      case 'wallet': return Icons.account_balance_wallet;
      default: return Icons.account_balance_wallet;
    }
  }
}
