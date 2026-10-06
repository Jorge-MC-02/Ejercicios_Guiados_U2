import 'package:flutter/material.dart';
import 'encrypted_json_storage.dart';

class JsonTestScreen extends StatefulWidget {
  const JsonTestScreen({super.key});

  @override
  State<JsonTestScreen> createState() => _JsonTestScreenState();
}

class _JsonTestScreenState extends State<JsonTestScreen> {
  final _storage = EncryptedJsonStorage();
  String _resultado = 'Sin datos todavía';

  Future<void> _guardar() async {
    await _storage.saveEncryptedJson('config_nodo.json', {
      'nodo': 'ESP32_01',
      'sensor': 'temperatura',
      'umbral': 35.0,
    });
    setState(() => _resultado = 'Archivo guardado y cifrado');
  }

  Future<void> _leer() async {
    final datos = await _storage.readEncryptedJson('config_nodo.json');
    setState(() => _resultado = datos?.toString() ?? 'No se pudo leer el archivo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON cifrado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(onPressed: _guardar, child: const Text('Guardar JSON cifrado')),
            ElevatedButton(onPressed: _leer, child: const Text('Leer y descifrar')),
            const SizedBox(height: 20),
            Text(_resultado),
          ],
        ),
      ),
    );
  }
}