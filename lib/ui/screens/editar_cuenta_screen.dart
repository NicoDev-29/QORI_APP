import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qori/models/models_exports.dart';
import 'package:qori/providers/cuenta_provider.dart';
import 'package:qori/themes/theme.dart';
import 'package:qori/ui/widgets/widgets_export.dart';

class EditarCuentaScreen extends StatefulWidget {
  final Cuenta cuenta;
  const EditarCuentaScreen({Key? key, required this.cuenta}) : super(key: key);

  @override
  State<EditarCuentaScreen> createState() => _EditarCuentaScreenState();
}

class _EditarCuentaScreenState extends State<EditarCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _saldoController;
  late TextEditingController _notaController;

  late String _tipoSeleccionado;
  late String _iconoSeleccionado;
  bool _isGuardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cuenta.nombre);
    _saldoController = TextEditingController(text: widget.cuenta.saldo.toStringAsFixed(2));
    _notaController = TextEditingController(text: widget.cuenta.nota ?? '');
    _tipoSeleccionado = widget.cuenta.tipo;
    _iconoSeleccionado = widget.cuenta.icono;
  }

  Future<void> _guardarEdicion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGuardando = true);

    final cuentaEditada = Cuenta(
      id: widget.cuenta.id,
      nombre: _nombreController.text,
      saldo: double.tryParse(_saldoController.text.replaceAll(',', '.')) ?? widget.cuenta.saldo,
      tipo: _tipoSeleccionado,
      icono: _iconoSeleccionado,
      nota: _notaController.text.isEmpty ? null : _notaController.text,
      createdAt: widget.cuenta.createdAt,
    );

    try {
      await Provider.of<CuentaProvider>(context, listen: false).actualizarCuenta(cuentaEditada);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
        title: const Text('Editar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
              const Text('Saldo', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _isGuardando ? null : _guardarEdicion,
                  child: _isGuardando
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(width: 10),
                            Text('Guardando...', style: TextStyle(fontSize: 16))
                          ],
                        )
                      : const Text('GUARDAR CAMBIOS', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
