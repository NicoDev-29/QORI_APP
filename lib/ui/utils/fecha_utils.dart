import 'package:qori/models/movimiento.dart';

String claveDia(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

Map<String, List<Movimiento>> agruparMovimientosPorDia(List<Movimiento> lista) {
  final Map<String, List<Movimiento>> res = {};
  for (final m in lista) {
    final diaKey = claveDia(m.fecha);  // Usa SIEMPRE m.fecha (que es createdAt)
    res.putIfAbsent(diaKey, () => []).add(m);
  }
  // Ordenar por fecha descendente
  final ordered = Map.fromEntries(
    res.entries.toList()
      ..sort((a, b) => b.value.first.fecha.compareTo(a.value.first.fecha)),
  );
  return ordered;
}

String horaBonita(DateTime fecha) {
  var h = fecha.hour.toString().padLeft(2, '0');
  var m = fecha.minute.toString().padLeft(2, '0');
  if (h == '00' && m == '00') return '';
  return '$h:$m';
}
