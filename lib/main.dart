import 'package:flutter/material.dart';
import 'modulo1/json_test_screen.dart';
import 'modulo1/csv_test_screen.dart';
import 'modulo1/preferences_screen.dart';
import 'modulo1/sensor_log_screen.dart';

void main() => runApp(const MaterialApp(home: MenuPrincipal()));

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unidad 2 - Persistencia')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _abrir(context, const JsonTestScreen()),
              child: const Text('Módulo 1A: JSON cifrado'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const CsvTestScreen()),
              child: const Text('Módulo 1: CSV con checksum'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const PreferencesScreen()),
              child: const Text('Ejercicio 1: Preferencias JSON'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const SensorLogScreen()),
              child: const Text('Evaluación: Log CSV'),
            ),
          ],
        ),
      ),
    );
  }
}