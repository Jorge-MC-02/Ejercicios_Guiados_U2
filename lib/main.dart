import 'package:flutter/material.dart';
import 'modulo1/json_test_screen.dart';
import 'modulo1/csv_test_screen.dart';
import 'modulo1/preferences_screen.dart';
import 'modulo1/sensor_log_screen.dart';
import 'modulo2/sqlite_test_screen.dart';
import 'modulo2/seed_data_screen.dart';
import 'modulo2/sql_injection_demo_screen.dart'; 
import 'modulo2/migration_test_screen.dart';
import 'modulo2/crud_test_screen.dart';

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
            ElevatedButton(
              onPressed: () => _abrir(context, const SqliteTestScreen()),
              child: const Text('Módulo 2: Prueba SQLite'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const SeedDataScreen()),
              child: const Text('Práctica 2: Histórico y Alertas'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const SqlInjectionDemoScreen()),
              child: const Text('Ejercicio: SQL Injection'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const MigrationTestScreen()),
              child: const Text('Prueba Migración v1→v2'),
            ),
            ElevatedButton(
              onPressed: () => _abrir(context, const CrudTestScreen()),
              child: const Text('Módulo 2: CRUD completo (U/D)'),
            ),
          ],
        ),
      ),
    );
  }
}