import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS data (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        desc TEXT,
        create_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'data.db',
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
      version: 1,
    );
  }

  static Future<int> createData(String item, String? desc) async {
    final db = await SQLHelper.db();

    final data = {
      'title': item,
      'desc': desc,
    };

    final id = db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();

    final data = await db.query('data');

    return data;
  }

  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();

    final data = await db.query('data', where: 'id = ?', whereArgs: [id]);

    return data;
  }

  static Future<int> updateData(int id, String item, String? desc) async {
    final db = await SQLHelper.db();

    final data = {
      'title': item,
      'desc': desc,
      'create_at': DateTime.now().toString(),
    };

    final result =
        await db.update('data', data, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete('data', where: 'id = ?', whereArgs: [id]);
    } catch (e) {}
  }
}
