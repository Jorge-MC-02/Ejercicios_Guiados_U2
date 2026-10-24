import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Modelo de Entidad
class SensorReading {
  final int? id;
  final String sensorType;
  final double value;
  final String timestamp;
  final String? ubicacionNodo;   // nuevo

  SensorReading({
    this.id,
    required this.sensorType,
    required this.value,
    required this.timestamp,
    this.ubicacionNodo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sensorType': sensorType,
      'value': value,
      'timestamp': timestamp,
      'ubicacion_nodo': ubicacionNodo,
    };
  }
}

// Modelo de Nodo
class IotNode {
  final int? id;
  final String name;
  final String sensorType;

  IotNode({this.id, required this.name, required this.sensorType});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'sensorType': sensorType};
}

// Modelo de Alerta (pertenece a un nodo)
class Alert {
  final int? id;
  final int nodeId;
  final String sensorType;
  final double value;
  final String timestamp;

  Alert({
    this.id,
    required this.nodeId,
    required this.sensorType,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'node_id': nodeId,
        'sensorType': sensorType,
        'value': value,
        'timestamp': timestamp,
      };
}

// Alerta con el nombre del nodo ya incluido (resultado del JOIN)
class AlertWithNode {
  final int id;
  final String nodeName;
  final String sensorType;
  final double value;
  final String timestamp;

  AlertWithNode({
    required this.id,
    required this.nodeName,
    required this.sensorType,
    required this.value,
    required this.timestamp,
  });
}

// Helper para Base de Datos (Patrón Singleton)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iot_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 2,                         // antes era 1
      onCreate: _createDB,
      onUpgrade: _onUpgrade,              // nuevo
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sensorType TEXT NOT NULL,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        ubicacion_nodo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sensorType TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        node_id INTEGER NOT NULL,
        sensorType TEXT NOT NULL,
        value REAL NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (node_id) REFERENCES nodes (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // Inserción parametrizada para PREVENIR SQL Injection (Create individual)
  Future<int> insertReading(SensorReading reading) async {
    final db = await instance.database;
    return await db.insert('readings', reading.toMap());
  }

  // Insertar un lote de lecturas dentro de una Transacción ACID (Create en lote)
  Future<void> insertBatchReadings(List<SensorReading> readings) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var reading in readings) {
        batch.insert('readings', reading.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  // Read: Consulta parametrizada (Segura)
  Future<List<SensorReading>> getReadingsByType(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'readings',
      where: 'sensorType = ?',
      whereArgs: [type],
      orderBy: 'id DESC',
    );

    return result.map((json) => SensorReading(
      id: json['id'] as int?,
      sensorType: json['sensorType'] as String,
      value: json['value'] as double,
      timestamp: json['timestamp'] as String,
      ubicacionNodo: json['ubicacion_nodo'] as String?,   // nuevo
    )).toList();
  }

  // UPDATE: actualiza una lectura existente, identificada por su id
  Future<int> updateReading(SensorReading reading) async {
    final db = await instance.database;
    return await db.update(
      'readings',
      reading.toMap(),
      where: 'id = ?',
      whereArgs: [reading.id],
    );
  }

  // DELETE: elimina una lectura por su id
  Future<int> deleteReading(int id) async {
    final db = await instance.database;
    return await db.delete(
      'readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Insertar un nodo, devuelve su id
  Future<int> insertNode(IotNode node) async {
    final db = await instance.database;
    return await db.insert('nodes', node.toMap());
  }
  
  // Insertar una alerta ligada a un nodo
  Future<int> insertAlert(Alert alert) async {
    final db = await instance.database;
    return await db.insert('alerts', alert.toMap());
  }
  
  // Consultar todas las alertas con el nombre de su nodo (JOIN)
  Future<List<AlertWithNode>> getAlertsWithNodeInfo() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT alerts.id, nodes.name AS nodeName, alerts.sensorType,
             alerts.value, alerts.timestamp
      FROM alerts
      INNER JOIN nodes ON alerts.node_id = nodes.id
      ORDER BY alerts.id DESC
    ''');
  
    return result.map((row) => AlertWithNode(
      id: row['id'] as int,
      nodeName: row['nodeName'] as String,
      sensorType: row['sensorType'] as String,
      value: row['value'] as double,
      timestamp: row['timestamp'] as String,
    )).toList();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE readings ADD COLUMN ubicacion_nodo TEXT');
    }
  }
}