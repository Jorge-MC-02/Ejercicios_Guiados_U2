import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserPreferences {
  final bool temaOscuro;
  final int intervaloMuestreoSegundos;

  UserPreferences({required this.temaOscuro, required this.intervaloMuestreoSegundos});

  Map<String, dynamic> toMap() => {
        'temaOscuro': temaOscuro,
        'intervaloMuestreoSegundos': intervaloMuestreoSegundos,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        temaOscuro: map['temaOscuro'] as bool,
        intervaloMuestreoSegundos: map['intervaloMuestreoSegundos'] as int,
      );
}

class PreferencesService {
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/user_preferences.json');
  }

  // Guarda las preferencias. Devuelve true si tuvo éxito, false si falló.
  Future<bool> savePreferences(UserPreferences prefs) async {
    try {
      final file = await _getLocalFile();
      final jsonString = jsonEncode(prefs.toMap());
      await file.writeAsString(jsonString);
      return true;
    } on FileSystemException catch (e) {
      print('Error de sistema de archivos al guardar preferencias: $e');
      return false;
    }
  }

  Future<UserPreferences?> loadPreferences() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) return null;
      final jsonString = await file.readAsString();
      return UserPreferences.fromMap(jsonDecode(jsonString));
    } on FileSystemException catch (e) {
      print('Error de sistema de archivos al leer preferencias: $e');
      return null;
    }
  }
}