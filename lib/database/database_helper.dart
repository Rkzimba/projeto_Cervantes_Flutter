import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;

    final dbPath = Directory.current.path;

    _db = await databaseFactory.openDatabase("$dbPath/cadastro.db");

    await _createTables(_db!);

    return _db!;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS cadastro(
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 texto TEXT NOT NULL,
 numero INTEGER NOT NULL UNIQUE
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS log(
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 operacao TEXT NOT NULL,
 data TEXT NOT NULL
)
''');
  }

  static Future inserir(String texto, int numero) async {
    final db = await database;

    await db.insert("cadastro", {"texto": texto, "numero": numero});

    await _log("INSERT");
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final db = await database;

    return await db.query("cadastro");
  }

  static Future atualizar(int id, String texto, int numero) async {
    final db = await database;

    await db.update(
      "cadastro",
      {"texto": texto, "numero": numero},
      where: "id = ?",
      whereArgs: [id],
    );

    await _log("UPDATE");
  }

  static Future deletar(int id) async {
    final db = await database;

    await db.delete("cadastro", where: "id = ?", whereArgs: [id]);

    await _log("DELETE");
  }

  static Future _log(String operacao) async {
    final db = await database;

    await db.insert("log", {
      "operacao": operacao,
      "data": DateTime.now().toString(),
    });
  }
}
