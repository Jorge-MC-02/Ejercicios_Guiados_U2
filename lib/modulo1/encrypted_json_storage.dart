import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptedJsonStorage {
  // Clave de 32 caracteres (AES-256) e IV de 16 caracteres
  final _key = encrypt.Key.fromUtf8('my32lengthsupersecretkey12345678');
  final _iv = encrypt.IV.fromUtf8('1234567890123456');

  Future<File> _getLocalFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  // Guardar JSON cifrado con escritura atómica (.tmp -> .json)
  Future<void> saveEncryptedJson(
      String filename, Map<String, dynamic> data) async {
    final file = await _getLocalFile(filename);
    final tempFile = File('${file.path}.tmp');

    final jsonString = jsonEncode(data);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encryptedData = encrypter.encrypt(jsonString, iv: _iv);

    // Se escribe primero en un archivo temporal y luego se renombra,
    // así el archivo final nunca queda a medias si algo falla.
    await tempFile.writeAsString(encryptedData.base64);
    await tempFile.rename(file.path);

    // print(await file.readAsString());   // línea temporal para la prueba
  }

  // Leer y descifrar JSON
  Future<Map<String, dynamic>?> readEncryptedJson(String filename) async {
    try {
      final file = await _getLocalFile(filename);
      if (!await file.exists()) return null;

      final encryptedText = await file.readAsString();
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decryptedText = encrypter.decrypt64(encryptedText, iv: _iv);
      return jsonDecode(decryptedText) as Map<String, dynamic>;
    } catch (e) {
      // Archivo corrupto o clave incorrecta
      print('Error al leer el archivo cifrado: $e');
      return null;
    }
  }
}