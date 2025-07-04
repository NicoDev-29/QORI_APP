import 'package:flutter/material.dart';
import '../../models/models_exports.dart';
import '../../constants/categoria_constants.dart';

class MovimientosAgrupadosPorFecha extends StatelessWidget {
  final List<Movimiento> movimientos;
  const MovimientosAgrupadosPorFecha({required this.movimientos, super.key});

  @override
  Widget build(BuildContext context) {
    // Agrupa por fecha (aaaa-mm-dd)
    final Map<String, List<Movimiento>> agrupados = {};
    for (final m in movimientos) {
      final key = '${m.fecha.year}-${m.fecha.month.toString().padLeft(2, '0')}-${m.fecha.day.toString().padLeft(2, '0')}';
      agrupados.putIfAbsent(key, () => []).add(m);
    }
    final fechas = agrupados.keys.toList()..sort((a, b) => b.compareTo(a)); // Descendente

    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fechas.length,
        itemBuilder: (context, idx) {
          final fecha = fechas[idx];
          final lista = agrupados[fecha]!;
          final fechaObj = lista.first.fecha;
          final fechaStr = '${_nombreDia(fechaObj.weekday)}, '
              '${fechaObj.day}/${fechaObj.month}/${fechaObj.year}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha separadora, con fondo suavemente gris
              Container(
                width: double.infinity,
                color: const Color(0xFFF6F6F6),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Text(
                  fechaStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFE0E0E0),
                  indent: 72, // para que la línea no llegue al icono
                  endIndent: 0,
                ),
                itemBuilder: (context, i) {
                  final mov = lista[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ListTile(
                      tileColor: Colors.white,
                      minVerticalPadding: 14,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: CategoriasConstants.colorPorCategoria(mov.categoria).withOpacity(0.16),
                        child: Icon(
                          CategoriasConstants.iconoPorCategoria(mov.categoria),
                          color: mov.tipo == TipoMovimiento.ingreso ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        '${mov.categoria} - ${mov.tipo == TipoMovimiento.ingreso ? '+' : '-'}S/. ${mov.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: mov.tipo == TipoMovimiento.ingreso ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: mov.nota != null && mov.nota!.isNotEmpty
                          ? Text(
                              mov.nota!,
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            )
                          : null,
                      trailing: _horaBonita(mov.fecha),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
            ],
          );
        },
      ),
    );
  }

  Widget _horaBonita(DateTime fecha) {
    var h = fecha.hour.toString().padLeft(2, '0');
    var m = fecha.minute.toString().padLeft(2, '0');
    // Si la hora y minuto son 00:00, no mostrar nada
    if (h == '00' && m == '00') return const SizedBox.shrink();
    return Text(
      '$h:$m',
      style: const TextStyle(fontSize: 13, color: Colors.grey),
    );
  }

  String _nombreDia(int weekday) {
    switch (weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mié';
      case 4: return 'Jue';
      case 5: return 'Vie';
      case 6: return 'Sáb';
      case 7: return 'Dom';
      default: return '';
    }
  }
}
