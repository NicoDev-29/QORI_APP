import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _mensaje;
  bool _procesando = false;

  Future<void> _tomarFotoYAnalizar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) await _procesarImagen(pickedFile.path);
  }

  Future<void> _seleccionarDesdeGaleria() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) await _procesarImagen(pickedFile.path);
  }

  Future<void> _procesarImagen(String path) async {
    setState(() {
      _procesando = true;
      _mensaje = null;
    });

    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final texto = recognizedText.text;

      final monto = _extraerMonto(texto);
      final categoria = _buscarCategoria(texto);
      final tipo = _definirTipo(texto);
      final nota = _extraerNota(texto);
      final fecha = _extraerFecha(texto) ?? DateTime.now();

      if (!mounted) return;
      Navigator.pushNamed(context, '/registro', arguments: {
        'tipo': tipo,
        'monto': monto,
        'categoria': categoria,
        'nota': nota,
        'fecha': fecha,
      });
    } catch (e) {
      setState(() => _mensaje = 'Error al procesar la imagen: $e');
    } finally {
      textRecognizer.close();
      setState(() => _procesando = false);
    }
  }

  void _abrirEscanerQR() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QRScannerScreen(
        onDetect: (String resultado) {
          Navigator.pop(context);
          try {
            final decoded = jsonDecode(resultado);
            if (decoded is Map<String, dynamic>) {
              Navigator.pushNamed(context, '/registro', arguments: {
                'tipo': decoded['tipo'] ?? 'Gasto',
                'monto': decoded['monto']?.toString(),
                'categoria': decoded['categoria'],
                'nota': decoded['nota'],
                'fecha': DateTime.tryParse(decoded['fecha'] ?? '') ?? DateTime.now(),
              });
              return;
            }
          } catch (_) {}
          Navigator.pushNamed(context, '/registro', arguments: {
            'nota': 'QR: $resultado',
            'fecha': DateTime.now(),
            'tipo': 'Gasto',
          });
        },
      ),
    ));
  }

  // === Funciones auxiliares corregidas ===

String _definirTipo(String texto) {
  final lower = texto.toLowerCase();
  if (lower.contains('boleta') || lower.contains('igv') || lower.contains('total') || lower.contains('recargo') || lower.contains('venta')) {
    return 'Gasto';
  }
  if (lower.contains('pago recibido') || lower.contains('deposito') || lower.contains('recibido') || lower.contains('ingreso')) {
    return 'Ingreso';
  }
  return 'Gasto'; // por defecto
}

String? _extraerMonto(String texto) {
  final lines = texto.split('\n');
  final regexMonto = RegExp(r'\d{1,5}[.,]\d{2}');

  final exclusion = [
    'igv', 'vuelto', 'efectivo', 'entregado', 'recibido',
    'subtotal', 'op. gravada', 'opgravada', 'mora', 'saldo', 'descuento',
    'serie', 'transaccion', 'dni', 'hora', 'codigo'
  ];

  List<double> posiblesMontos = [];

  for (final line in lines) {
    final lineLower = line.toLowerCase();
    if (exclusion.any((e) => lineLower.contains(e))) continue;

    final matches = regexMonto.allMatches(lineLower);
    for (final match in matches) {
      final montoStr = match.group(0)!.replaceAll(',', '.');
      final monto = double.tryParse(montoStr);

      if (monto != null && monto > 0.5 && monto < 10000) {
        posiblesMontos.add(monto);
      }
    }
  }

  if (posiblesMontos.isEmpty) return null;

  // 🧠 Corrección OCR: si hay un monto muy similar pero menor (como 2.00 vs 20.00), usar el menor
  for (var i = 0; i < posiblesMontos.length; i++) {
    for (var j = i + 1; j < posiblesMontos.length; j++) {
      final a = posiblesMontos[i];
      final b = posiblesMontos[j];
      if ((a - b).abs() >= 9.5 && (a - b).abs() <= 18.5) {
        // 20.00 vs 2.00 o 200.00 vs 20.00 → sospechoso
        final menor = a < b ? a : b;
        return menor.toStringAsFixed(2);
      }
    }
  }

  // ✅ Si todo está bien, devuelve el mayor monto como antes
  return posiblesMontos.reduce((a, b) => a > b ? a : b).toStringAsFixed(2);
}




DateTime? _extraerFecha(String texto) {
  final match = RegExp(r'(\d{2})[-/](\d{2})[-/](\d{4})').firstMatch(texto);
  if (match != null) {
    try {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      return DateTime(year, month, day);
    } catch (_) {}
  }
  return null;
}


String _buscarCategoria(String texto) {
  final lower = texto.toLowerCase();
  final tipo = _definirTipo(texto);

  if (tipo == 'Ingreso') {
    if (lower.contains('salario') || lower.contains('sueldo')) return 'Salario';
    if (lower.contains('familia') || lower.contains('familiar')) return 'Familia';
    if (lower.contains('inversión') || lower.contains('interes')) return 'Inversión';
    if (lower.contains('bono')) return 'Bono';
    if (lower.contains('dividendo')) return 'Dividendo';
    if (lower.contains('prestamo') || lower.contains('préstamo')) return 'Préstamo';
    if (lower.contains('regalo')) return 'Regalo';
    if (lower.contains('premio')) return 'Premio';
    return 'Otro ingreso';
  } else {
    if (lower.contains('tec') || lower.contains('educación') || lower.contains('curso') || lower.contains('nivel')) return 'Educación';
    if (lower.contains('pedido') || lower.contains('delivery')) return 'Comida';
    if (lower.contains('servicio') || lower.contains('recibo') || lower.contains('luz') || lower.contains('agua')) return 'Servicios';
    if (lower.contains('compra') || lower.contains('producto')) return 'Compras';
    if (lower.contains('movilidad') || lower.contains('transporte')) return 'Transporte';
    if (lower.contains('hospital') || lower.contains('salud')) return 'Salud';
    if (lower.contains('ocio') || lower.contains('cine')) return 'Ocio';
    if (lower.contains('hogar') || lower.contains('alquiler')) return 'Hogar';
    if (lower.contains('vehículo') || lower.contains('mantenimiento')) return 'Vehículo';
    return 'Otro gasto';
  }
}


  String? _extraerNota(String texto) {
    final lines = texto.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return lines.length >= 3 ? lines.sublist(0, 3).join(' ') : texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Boleta o QR')),
      body: Center(
        child: _procesando
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto de Boleta'),
                    onPressed: _tomarFotoYAnalizar,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Elegir desde Galería'),
                    onPressed: _seleccionarDesdeGaleria,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Escanear Código QR'),
                    onPressed: _abrirEscanerQR,
                  ),
                  if (_mensaje != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_mensaje!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  final void Function(String) onDetect;
  const QRScannerScreen({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final valor = barcode.rawValue;
          if (valor != null) {
            onDetect(valor);
          }
        },
      ),
    );
  }
}
