import 'dart:math';
import 'package:flutter/material.dart';
import 'csv_node_manager.dart';

class SensorLogScreen extends StatefulWidget {
  const SensorLogScreen({super.key});

  @override
  State<SensorLogScreen> createState() => _SensorLogScreenState();
}

class _SensorLogScreenState extends State<SensorLogScreen> {
  final _manager = CsvNodeManager();
  String? _filePath;
  bool? _esValido;
  String _mensaje = 'Aún no se ha generado el log';

  Future<void> _generarLog() async {
    final random = Random();
    final List<List<dynamic>> filas = [
      ['sensor_type', 'value_celsius', 'timestamp'],
    ];

    final ahora = DateTime.now();
    for (int i = 0; i < 100; i++) {
      final lectura = 20 + random.nextDouble() * 15; // 20°C a 35°C
      final momento = ahora.subtract(Duration(minutes: 100 - i));
      filas.add([
        'temperature',
        lectura.toStringAsFixed(2),
        momento.toIso8601String(),
      ]);
    }

    final path = await _manager.exportNodesToCsv(filas);
    setState(() {
      _filePath = path;
      _esValido = null;
      _mensaje = '100 lecturas generadas';
    });
  }

  Future<void> _validarLog() async {
    if (_filePath == null) {
      setState(() => _mensaje = 'Primero genera el log');
      return;
    }
    final ok = await _manager.verifyAndImportCsv(_filePath!);
    setState(() {
      _esValido = ok;
      _mensaje = ok ? 'Integridad válida' : 'Log corrupto o alterado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log de Sensores')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _generarLog,
              child: const Text('Generar Log de Sensores (CSV)'),
            ),
            ElevatedButton(
              onPressed: _validarLog,
              child: const Text('Validar Integridad Log'),
            ),
            const SizedBox(height: 24),
            if (_esValido != null)
              Icon(
                _esValido! ? Icons.check_circle : Icons.cancel,
                color: _esValido! ? Colors.green : Colors.red,
                size: 72,
              ),
            const SizedBox(height: 12),
            Text(_mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}