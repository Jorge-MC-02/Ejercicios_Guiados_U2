import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class SqliteTestScreen extends StatefulWidget {
  const SqliteTestScreen({super.key});

  @override
  State<SqliteTestScreen> createState() => _SqliteTestScreenState();
}

class _SqliteTestScreenState extends State<SqliteTestScreen> {
  String _mensaje = 'Sin datos aún';

  Future<void> _insertarLecturas() async {
    final random = Random();
    final ahora = DateTime.now();
    final lecturas = List.generate(5, (i) => SensorReading(
      sensorType: 'temperature',
      value: 20 + random.nextDouble() * 15,
      timestamp: ahora.subtract(Duration(minutes: i)).toIso8601String(),
    ));

    await DatabaseHelper.instance.insertBatchReadings(lecturas);
    setState(() => _mensaje = '5 lecturas insertadas');
  }

  Future<void> _consultar() async {
    final lecturas = await DatabaseHelper.instance.getReadingsByType('temperature');
    setState(() => _mensaje = 'Hay ${lecturas.length} lecturas guardadas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba SQLite')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _insertarLecturas, child: const Text('Insertar lecturas')),
            ElevatedButton(onPressed: _consultar, child: const Text('Consultar lecturas')),
            const SizedBox(height: 20),
            Text(_mensaje),
          ],
        ),
      ),
    );
  }
}