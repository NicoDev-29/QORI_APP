import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qori/models/models_exports.dart';
import 'package:qori/providers/providers_export.dart';
import '../widgets/widgets_export.dart';

class AgregarCuentaScreen extends StatefulWidget {
  const AgregarCuentaScreen({super.key});

  @override
  State<AgregarCuentaScreen> createState() => _AgregarCuentaScreenState();
}

class _AgregarCuentaScreenState extends State<AgregarCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _saldoController = TextEditingController();
  final _notaController = TextEditingController();

  String _tipoSeleccionado = 'Ahorro';
  String _iconoSeleccionado = 'wallet';
  bool _isGuardando = false;

  Future<void> _guardarCuenta() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isGuardando = true);
    
    final cuenta = Cuenta(
      id: '',
      nombre: _nombreController.text,
      saldo: double.tryParse(_saldoController.text.replaceAll(',', '.')) ?? 0.0,
      tipo: _tipoSeleccionado,
      icono: _iconoSeleccionado,
      nota: _notaController.text.isEmpty ? null : _notaController.text,
      createdAt: Timestamp.now(),
    );

    try {
      await context.read<CuentaProvider>().agregarCuenta(cuenta);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta agregada exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGuardando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _saldoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de cuenta', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TipoCuentaSelector(
                tipoSeleccionado: _tipoSeleccionado,
                onChanged: (nuevoTipo) => setState(() => _tipoSeleccionado = nuevoTipo),
              ),
              const SizedBox(height: 24),
              const Text('Ícono', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              IconoCuentaSelector(
                iconoSeleccionado: _iconoSeleccionado,
                onChanged: (nuevoIcono) => setState(() => _iconoSeleccionado = nuevoIcono),
              ),
              const SizedBox(height: 24),
              const Text('Nombre de la cuenta', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                controller: _nombreController,
                hintText: 'Ejemplo: Billetera, Tarjeta BCP...',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obligatorio';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text('Saldo inicial', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                controller: _saldoController,
                hintText: 'Ej: 500.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obligatorio';
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text('Nota (opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                controller: _notaController,
                hintText: 'Descripción breve...',
                maxLines: 2,
                isRequired: false,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isGuardando ? null : _guardarCuenta,
                  child: _isGuardando
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(width: 10),
                            Text('Guardando...', style: TextStyle(fontSize: 16))
                          ],
                        )
                      : const Text('GUARDAR CUENTA', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
