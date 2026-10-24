import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class SqlInjectionDemoScreen extends StatefulWidget {
  const SqlInjectionDemoScreen({super.key});

  @override
  State<SqlInjectionDemoScreen> createState() => _SqlInjectionDemoScreenState();
}

class _SqlInjectionDemoScreenState extends State<SqlInjectionDemoScreen> {
  final _controller = TextEditingController(text: "'); DROP TABLE readings; --");
  String _resultado = '';

  // Versión SEGURA (parametrizada)
  Future<void> _probarVersionSegura() async {
    final db = await DatabaseHelper.instance.database;
    try {
      await db.rawInsert(
        'INSERT INTO nodes (name, sensorType) VALUES (?, ?)',
        [_controller.text, 'temperature'],
      );
      setState(() => _resultado =
          'Insertado de forma segura. El texto se guardó tal cual, como dato, sin ejecutar nada.');
    } catch (e) {
      setState(() => _resultado = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo SQL Injection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Texto de entrada'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _probarVersionSegura,
              child: const Text('Insertar con parámetros (seguro)'),
            ),
            const SizedBox(height: 20),
            Text(_resultado),
          ],
        ),
      ),
    );
  }
}