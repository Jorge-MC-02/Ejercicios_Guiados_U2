import 'package:flutter/material.dart';
import 'preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _service = PreferencesService();
  bool _temaOscuro = false;
  double _intervalo = 10;

  Future<void> _guardar() async {
    final prefs = UserPreferences(
      temaOscuro: _temaOscuro,
      intervaloMuestreoSegundos: _intervalo.round(),
    );
    final exito = await _service.savePreferences(prefs);

    if (!mounted) return; // buena práctica tras un await, evita usar context si el widget ya no existe

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito ? 'Preferencias guardadas' : 'Error al guardar preferencias'),
        backgroundColor: exito ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _cargar() async {
    final prefs = await _service.loadPreferences();
    if (prefs != null) {
      setState(() {
        _temaOscuro = prefs.temaOscuro;
        _intervalo = prefs.intervaloMuestreoSegundos.toDouble();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Tema oscuro'),
              value: _temaOscuro,
              onChanged: (v) => setState(() => _temaOscuro = v),
            ),
            Text('Intervalo de muestreo: ${_intervalo.round()} s'),
            Slider(
              value: _intervalo,
              min: 1,
              max: 60,
              divisions: 59,
              label: '${_intervalo.round()} s',
              onChanged: (v) => setState(() => _intervalo = v),
            ),
            ElevatedButton(onPressed: _guardar, child: const Text('Guardar preferencias')),
          ],
        ),
      ),
    );
  }
}