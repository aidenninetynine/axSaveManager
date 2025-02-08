import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import '../instance.dart';
import '../save_file.dart';
import 'dart:io';

class DataProvider {
  static Database? _database;

  // Database initialization
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS ) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, 'undertaleFiles.db');
    print(path);
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Instances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        folderName TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE SaveFiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        folderName TEXT,
        instanceId INTEGER,
        FOREIGN KEY (instanceId) REFERENCES Instances(id)
      )
    ''');
    // Insert initial data (optional - for example purposes)
    // await _insertInitialData(db);
  }

  static Future<int> deleteInstance(int id) async {
    final db = await database;
    return await db.delete(
    'Instances',
    where: 'id = ?',
    whereArgs: [id],
    );
  }

  static Future<int> deleteSaveFile(int id) async {
    final db = await database;
    return await db.delete(
      'SaveFiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> _insertInitialData(Database db) async {
    await db.insert('Instances', {'id': 1, 'name': 'SillyBilly', 'folderName': 'shityourself'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('SaveFiles', {'id': 101, 'name': 'Save 1 - Level 1', 'folderName': 'saves', 'instanceId': 1}, conflictAlgorithm: ConflictAlgorithm.replace);
  }


  static Future<List<Instance>> getInstances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Instances');
    return List.generate(maps.length, (i) {
      return Instance.fromJson(maps[i]);
    });
  }

  static Future<List<SaveFile>> getSaveFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('SaveFiles');
    return List.generate(maps.length, (i) {
      return SaveFile.fromJson(maps[i]);
    });
  }

  static Future<List<SaveFile>> getSaveFilesByInstanceId(int instanceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SaveFiles',
      where: 'instanceId = ?',
      whereArgs: [instanceId],
    );
    return List.generate(maps.length, (i) {
      return SaveFile.fromJson(maps[i]);
    });
  }

  // Methods to Insert Data (optional for now, but good to have)
  static Future<int> insertInstance(Instance instance) async {
    final db = await database;
    return await db.insert('Instances', instance.toJson());
  }

  static Future<int> insertSaveFile(SaveFile saveFile) async {
    final db = await database;
    return await db.insert('SaveFiles', saveFile.toJson());
  }
}