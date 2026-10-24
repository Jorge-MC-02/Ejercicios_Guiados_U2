import 'package:flutter/material.dart';
import 'database_helper.dart';

class CrudTestScreen extends StatefulWidget {
  const CrudTestScreen({super.key});

  @override
  State<CrudTestScreen> createState() => _CrudTestScreenState();
}

class _CrudTestScreenState extends State<CrudTestScreen> {
  List<SensorReading> _lecturas = [];
  String _mensaje = 'Sin consultar aún';

  Future<void> _consultar() async {
    final lecturas = await DatabaseHelper.instance.getReadingsByType('temperature');
    setState(() {
      _lecturas = lecturas;
      _mensaje = 'Hay ${lecturas.length} lecturas';
    });
  }

  Future<void> _actualizarPrimera() async {
    if (_lecturas.isEmpty) {
      setState(() => _mensaje = 'No hay lecturas para actualizar');
      return;
    }
    final original = _lecturas.first;
    final actualizada = SensorReading(
      id: original.id,
      sensorType: original.sensorType,
      value: 99.9,
      timestamp: original.timestamp,
      ubicacionNodo: 'Actualizado_Manual',
    );
    final filasAfectadas = await DatabaseHelper.instance.updateReading(actualizada);
    final lecturas = await DatabaseHelper.instance.getReadingsByType('temperature');
    setState(() {
      _lecturas = lecturas;_mensaje = 'UPDATE: $filasAfectadas fila(s) modificada(s). Hay ${lecturas.length} lecturas.';
    });
  }
  
  Future<void> _borrarUltima() async {
    if (_lecturas.isEmpty) {
      setState(() => _mensaje = 'No hay lecturas para borrar');
      return;
    }
    final ultima = _lecturas.last;
    final filasAfectadas = await DatabaseHelper.instance.deleteReading(ultima.id!);
    final lecturas = await DatabaseHelper.instance.getReadingsByType('temperature');
    setState(() {
      _lecturas = lecturas;
      _mensaje = 'DELETE: $filasAfectadas fila(s) eliminada(s). Hay ${lecturas.length} lecturas.';
    });
  }

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba CRUD completo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _consultar, child: const Text('Consultar (R)')),
            ElevatedButton(onPressed: _actualizarPrimera, child: const Text('Actualizar primera (U)')),
            ElevatedButton(onPressed: _borrarUltima, child: const Text('Borrar última (D)')),
            const SizedBox(height: 12),
            Text(_mensaje, textAlign: TextAlign.center),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _lecturas.length,
                itemBuilder: (context, index) {
                  final r = _lecturas[index];
                  return ListTile(
                    title: Text('id ${r.id}: ${r.value} °C — ${r.ubicacionNodo ?? "sin ubicación"}'),
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