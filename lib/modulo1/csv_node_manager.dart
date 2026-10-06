import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class CsvNodeManager {
  Future<String> exportNodesToCsv(List<List<dynamic>> rows) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/iot_nodes_config.csv';
    final file = File(filePath);

    // Convertir la lista a texto CSV (salto de línea fijo: \n)
    final String csvData = const ListToCsvConverter(eol: '\n').convert(rows);

    // Calcular el checksum SHA-256 del contenido
    final bytes = utf8.encode(csvData);
    final checksum = sha256.convert(bytes).toString();

    // Primera línea: checksum. Después: los datos.
    final String fileContent = '# CHECKSUM:$checksum\n$csvData';
    await file.writeAsString(fileContent);

    return filePath;
  }

  Future<bool> verifyAndImportCsv(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final List<String> lines = await file.readAsLines();
    if (lines.isEmpty || !lines[0].startsWith('# CHECKSUM:')) return false;

    final String originalChecksum =
        lines[0].replaceFirst('# CHECKSUM:', '').trim();
    final String csvBody = lines.sublist(1).join('\n');

    // Recalcular el SHA-256 y comparar
    final recalculated = sha256.convert(utf8.encode(csvBody)).toString();

    if (originalChecksum == recalculated) {
      final List<List<dynamic>> parsed =
          const CsvToListConverter(eol: '\n').convert(csvBody);
      print('Datos de nodos válidos cargados correctamente: $parsed');
      return true;
    } else {
      print('ALERTA DE SEGURIDAD: El archivo CSV ha sido alterado o está corrupto.');
      return false;
    }
  }
}