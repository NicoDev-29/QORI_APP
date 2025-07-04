import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/providers/presupuesto_provider.dart';
import 'package:qori/providers/movimiento_provider.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/models/models_exports.dart';
import 'package:qori/models/presupuesto.dart';
import 'package:qori/ui/widgets/movimiento_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presupuestoProvider = Provider.of<PresupuestoProvider>(context);
    final movimientoProvider = Provider.of<MovimientoProvider>(context);
    final hoy = DateTime.now();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: StreamBuilder<List<Presupuesto>>(
        stream: presupuestoProvider.presupuestosStream,
        builder: (context, presSnapshot) {
          final presupuestos = presSnapshot.data ?? [];
          final totalPresupuesto = presupuestos.fold(0.0, (a, b) => a + b.monto);

          return StreamBuilder<List<Movimiento>>(
            stream: movimientoProvider.streamTodosLosMovimientos(),
            builder: (context, movSnapshot) {
              final movimientos = movSnapshot.data ?? [];
              final movimientosDelMes = movimientos.where((m) =>
                  m.fecha.year == hoy.year && m.fecha.month == hoy.month
                ).toList();
              final movsHoy = movimientos.where((m) =>
                  m.fecha.year == hoy.year &&
                  m.fecha.month == hoy.month &&
                  m.fecha.day == hoy.day
                ).toList();

              final restante = presupuestoProvider.presupuestoTotalRestanteConLista(
                movimientosDelMes, presupuestos
              );
              final porcentaje = totalPresupuesto > 0
                ? (restante / totalPresupuesto * 100).clamp(0, 100)
                : 0.0;
              final totalIngresos = movimientosDelMes
                  .where((m) => m.tipo.toLowerCase() == 'ingreso')
                  .fold(0.0, (sum, m) => sum + m.monto);
              final totalEgresos = movimientosDelMes
                  .where((m) => m.tipo.toLowerCase() == 'gasto')
                  .fold(0.0, (sum, m) => sum + m.monto);

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Encabezado
                  Container(
                    padding: EdgeInsets.fromLTRB(width * 0.05, 44, width * 0.05, 20),
                    color: AppColors.primary,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: width * 0.07,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppColors.primary, size: width * 0.09),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Hola, Regina Pérez',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                )),
                              SizedBox(height: 2),
                              Text('¡Bienvenido!',
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications, color: Colors.white, size: 28),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Presupuesto mensual
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 20),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/presupuestos'),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: width * 0.06,
                          horizontal: width * 0.05,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Círculo de progreso
                            Container(
                              width: width * 0.20, 
                              height: width * 0.20,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Círculo de progreso
                                  SizedBox(
                                    width: width * 0.30,
                                    height: width * 0.30,
                                    child: CircularProgressIndicator(
                                      value: porcentaje / 100,
                                      strokeWidth: 10, // Línea más fina
                                      backgroundColor: AppColors.backgroundLight2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        porcentaje > 50
                                            ? Colors.green
                                            : (porcentaje > 20 ? Colors.amber : Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                  // Contenido centrado
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${porcentaje.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.055, // Tamaño más pequeño
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'restante',
                                        style: TextStyle(
                                          fontSize: width * 0.028,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: width * 0.04),
                            
                            // Información del presupuesto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Presupuesto mensual',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.04,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: width * 0.01),
                                  Text(
                                    'S/. ${totalPresupuesto.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.052,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: width * 0.015),
                                  
                                  // Ingresos y egresos
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Ingresos
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.arrow_upward,
                                              color: Colors.green,
                                              size: 14,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Ingresos: S/. ${totalIngresos.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      
                                      // Egresos
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              Icons.arrow_downward,
                                              color: Colors.red,
                                              size: 14,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Egresos: S/. ${totalEgresos.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: width * 0.035,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: width * 0.015),
                                  
                                  // Monto restante
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundLight2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Restante: S/. ${restante.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: width * 0.035,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Icono de flecha
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Movimientos de hoy
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Movimientos de hoy',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        movsHoy.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('No hay movimientos hoy.', style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: movsHoy.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFE0E0E0),
                                  indent: 76,
                                  endIndent: 8,
                                ),
                                itemBuilder: (context, idx) => MovimientoItem(movimiento: movsHoy[idx]),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}