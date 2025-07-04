import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/providers/cuenta_provider.dart';
import 'package:qori/themes/theme.dart';
import 'screens_exports.dart';

class CuentasScreen extends StatelessWidget {
  const CuentasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Consumer<CuentaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.cuentas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay cuentas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega tu primera cuenta',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, const Color.fromARGB(255, 231, 187, 55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Patrimonio neto',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Icon(Icons.trending_up, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S/. ${provider.patrimonioNeto.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Activos',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'S/. ${provider.totalActivos.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Pasivos',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'S/. ${provider.totalPasivos.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.cuentas.length,
                  itemBuilder: (context, index) {
                    final cuenta = provider.cuentas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.backgroundLight,
                          child: Icon(
                            _getIconData(cuenta.icono),
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          cuenta.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_getTipoText(cuenta.tipo)),
                        trailing: Text(
                          'S/. ${cuenta.saldo.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cuenta.tipo == 'Crédito'
                                ? Colors.red
                                : AppColors.backgroundDark,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CuentaDetalleScreen(cuenta: cuenta),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/agregar_cuenta'),
        backgroundColor: AppColors.primary,
        label: const Text(
          'Agregar Cuenta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _getTipoText(String tipo) {
    switch (tipo) {
      case 'Ahorro':
        return 'Cuenta de ahorro';
      case 'Débito':
        return 'Tarjeta de débito';
      case 'Crédito':
        return 'Tarjeta de crédito';
      default:
        return tipo;
    }
  }
}
