import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qori/constants/categoria_constants.dart';
import 'package:qori/providers/movimiento_provider.dart';
import 'package:qori/models/movimiento.dart';
import 'package:qori/ui/widgets/widgets_export.dart';
import 'package:qori/providers/cuenta_provider.dart'; // NUEVO

class AgregarMovimientoScreen extends StatefulWidget {
  const AgregarMovimientoScreen({Key? key}) : super(key: key);

  @override
  State<AgregarMovimientoScreen> createState() => _AgregarMovimientoScreenState();
}

class _AgregarMovimientoScreenState extends State<AgregarMovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String _tipoMovimiento = TipoMovimiento.gasto;
  String? _categoriaSeleccionada;
  String? _cuentaSeleccionada;
  bool _guardando = false;

  List<Map<String, dynamic>> get categoriasDisponibles =>
      CategoriasConstants.getCategoriasPorTipo(_tipoMovimiento);

  void _onTipoMovimientoChanged(String nuevoTipo) {
    setState(() {
      _tipoMovimiento = nuevoTipo;
      _categoriaSeleccionada = null;
    });
  }

  Future<void> _guardarMovimiento() async {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null) {
        _mostrarError('Por favor selecciona una categoría');
        return;
      }
      if (_fechaSeleccionada == null) {
        _mostrarError('Por favor selecciona una fecha');
        return;
      }
      if (_cuentaSeleccionada == null) {
        _mostrarError('Por favor selecciona una cuenta');
        return;
      }

      setState(() { _guardando = true; });

      final movimiento = Movimiento(
        id: '',
        tipo: _tipoMovimiento,
        categoria: _categoriaSeleccionada!,
        monto: double.parse(_montoController.text),
        nota: _notaController.text.isEmpty ? null : _notaController.text,
        cuentaId: _cuentaSeleccionada!, // NUEVO
        createdAt: Timestamp.now(),
      );

      try {
        await context.read<MovimientoProvider>().agregarMovimiento(movimiento);

        _mostrarConfirmacion('¡Movimiento guardado exitosamente!');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.pop(context);
      } catch (e) {
        _mostrarError('Error al guardar: $e');
      } finally {
        if (mounted) setState(() { _guardando = false; });
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarConfirmacion(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('¡Movimiento guardado exitosamente!')),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.06;
    final cuentasProvider = Provider.of<CuentaProvider>(context);
    final cuentas = cuentasProvider.cuentas;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Agregar Movimiento', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de cuenta
              const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _cuentaSeleccionada,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  filled: true,
                  fillColor: Color(0xFFE8F5E9),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: cuentas.map((cuenta) {
                  return DropdownMenuItem(
                    value: cuenta.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cuenta.nombre}'),
                        Text(
                          'S/. ${cuenta.saldo.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: cuenta.tipo.toLowerCase() == 'credito' ? Colors.red : Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _cuentaSeleccionada = value),
                validator: (value) => value == null ? 'Selecciona una cuenta' : null,
              ),
              const SizedBox(height: 16),
              // ... (el resto de los campos iguales)
              const Text('Tipo de Movimiento', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TipoMovimientoSelector(
                tipoSeleccionado: _tipoMovimiento,
                onChanged: _onTipoMovimientoChanged,
              ),
              const SizedBox(height: 20),
              const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              CategoriaSelector(
                categorias: categoriasDisponibles,
                seleccionada: _categoriaSeleccionada,
                onChanged: (cat) => setState(() => _categoriaSeleccionada = cat),
              ),
              const SizedBox(height: 20),
              const Text('Monto', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                controller: _montoController,
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
              ),
              const SizedBox(height: 20),
              const Text('Fecha', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DatePickerField(
                selectedDate: _fechaSeleccionada,
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaSeleccionada ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) setState(() => _fechaSeleccionada = fecha);
                },
              ),
              const SizedBox(height: 20),
              const Text('Nota (Opcional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              InputField(
                controller: _notaController,
                hintText: 'Descripción breve...',
                maxLines: 3,
                isRequired: false,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _guardando ? null : _guardarMovimiento,
                  child: _guardando
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text('Guardar Movimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
