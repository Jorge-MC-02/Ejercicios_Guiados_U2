import 'dart:io';
import 'package:flutter/material.dart';
import 'csv_node_manager.dart';

class CsvTestScreen extends StatefulWidget {
  const CsvTestScreen({super.key});

  @override
  State<CsvTestScreen> createState() => _CsvTestScreenState();
}

class _CsvTestScreenState extends State<CsvTestScreen> {
  final _manager = CsvNodeManager();
  String? _filePath;
  String _mensaje = 'Aún no se ha exportado nada';
  bool? _valido;

  // Encabezado + nodos de ejemplo
  final List<List<dynamic>> _nodos = [
    ['node_id', 'sensor_type', 'location', 'sampling_seconds'],
    ['ESP32_01', 'temperature', 'Laboratorio', 10],
    ['ESP32_02', 'humidity', 'Bodega', 15],
    ['ESP32_03', 'temperature', 'Oficina', 30],
  ];

  Future<void> _exportar() async {
    final path = await _manager.exportNodesToCsv(_nodos);
    setState(() {
      _filePath = path;
      _valido = null;
      _mensaje = 'CSV exportado en:\n$path';
    });
  }

  Future<void> _verificar() async {
    if (_filePath == null) {
      setState(() => _mensaje = 'Primero exporta el CSV');
      return;
    }
    final ok = await _manager.verifyAndImportCsv(_filePath!);
    setState(() {
      _valido = ok;
      _mensaje = ok ? 'Integridad correcta' : 'Archivo alterado o corrupto';
    });
  }

  // Solo para la prueba: agrega una línea al archivo sin recalcular el checksum
  Future<void> _alterarArchivo() async {
    if (_filePath == null) return;
    await File(_filePath!).writeAsString(
      '\nESP32_99,temperature,Intruso,1',
      mode: FileMode.append,
    );
    setState(() {
      _valido = null;
      _mensaje = 'Archivo alterado (simulación). Ahora verifica.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV con checksum')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _exportar, child: const Text('Exportar nodos a CSV')),
            ElevatedButton(onPressed: _verificar, child: const Text('Verificar e importar')),
            ElevatedButton(onPressed: _alterarArchivo, child: const Text('Simular alteración')),
            const SizedBox(height: 20),
            if (_valido != null)
              Icon(
                _valido! ? Icons.check_circle : Icons.cancel,
                color: _valido! ? Colors.green : Colors.red,
                size: 64,
              ),
            const SizedBox(height: 12),
            Text(_mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}