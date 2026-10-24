import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'historical_alerts_screen.dart';

class SeedDataScreen extends StatefulWidget {
  const SeedDataScreen({super.key});

  @override
  State<SeedDataScreen> createState() => _SeedDataScreenState();
}

class _SeedDataScreenState extends State<SeedDataScreen> {
  String _mensaje = 'Sin datos generados';

  Future<void> _generarNodosYAlertas() async {
    final random = Random();
    final db = DatabaseHelper.instance;

    // Crear 2 nodos de ejemplo
    final idNodo1 = await db.insertNode(
      IotNode(name: 'ESP32_Laboratorio', sensorType: 'temperature'),
    );
    final idNodo2 = await db.insertNode(
      IotNode(name: 'ESP32_Bodega', sensorType: 'temperature'),
    );

    // Generar alertas aleatorias para cada nodo
    final ahora = DateTime.now();
    for (int i = 0; i < 5; i++) {
      await db.insertAlert(Alert(
        nodeId: idNodo1,
        sensorType: 'temperature',
        value: 30 + random.nextDouble() * 10, // algunas pasan de 35
        timestamp: ahora.subtract(Duration(minutes: i * 10)).toIso8601String(),
      ));
      await db.insertAlert(Alert(
        nodeId: idNodo2,
        sensorType: 'temperature',
        value: 25 + random.nextDouble() * 8,
        timestamp: ahora.subtract(Duration(minutes: i * 7)).toIso8601String(),
      ));
    }

    setState(() => _mensaje = 'Nodos y alertas generados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar datos (Práctica 2)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _generarNodosYAlertas,
              child: const Text('Generar nodos y alertas'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricalAlertsScreen()),
              ),
              child: const Text('Ver histórico de alertas'),
            ),
            const SizedBox(height: 20),
            Text(_mensaje),
          ],
        ),
      ),
    );
  }
}