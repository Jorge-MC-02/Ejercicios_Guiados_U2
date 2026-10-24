import 'package:flutter/material.dart';
import 'database_helper.dart';

class MigrationTestScreen extends StatefulWidget {
  const MigrationTestScreen({super.key});

  @override
  State<MigrationTestScreen> createState() => _MigrationTestScreenState();
}

class _MigrationTestScreenState extends State<MigrationTestScreen> {
  List<SensorReading> _lecturas = [];
  String _mensaje = 'Sin consultar aún';

  Future<void> _consultar() async {
    final lecturas = await DatabaseHelper.instance.getReadingsByType('temperature');
    setState(() {
      _lecturas = lecturas;
      _mensaje = 'Se encontraron ${lecturas.length} lecturas (deben ser las mismas de antes de migrar)';
    });
  }

  Future<void> _insertarConUbicacion() async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('readings', SensorReading(
      sensorType: 'temperature',
      value: 27.5,
      timestamp: DateTime.now().toIso8601String(),
      ubicacionNodo: 'Invernadero_Norte',
    ).toMap());
    await _consultar();
  }

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Migración v1 → v2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _insertarConUbicacion,
              child: const Text('Insertar lectura CON ubicación'),
            ),
            ElevatedButton(onPressed: _consultar, child: const Text('Refrescar lista')),
            const SizedBox(height: 12),
            Text(_mensaje),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _lecturas.length,
                itemBuilder: (context, index) {
                  final r = _lecturas[index];
                  return ListTile(
                    title: Text('${r.value} °C — ${r.ubicacionNodo ?? "(sin ubicación, registro antiguo)"}'),
                    subtitle: Text(r.timestamp),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}