import "package:sqflite/sqflite.dart" as sql;

class DBHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  title TEXT,
  desc TEXT,
  is_done BOOLEAN NOT NULL DEFAULT FALSE,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "todo_list_sqlite.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
      // onUpgrade: (sql.Database database, oldVersion, newVersion) async {
      //   await database.execute(
      //       """ALTER TABLE tasks ADD COLUMN is_done BOOLEAN DEFAULT FALSE""");
      // },
    );
  }

  static Future<int> createData(String title, String? desc) async {
    final db = await DBHelper.db();

    final data = {"title": title, "desc": desc};
    final id = await db.insert("data", data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await DBHelper.db();
    return db.query("data", orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getDataById(int id) async {
    final db = await DBHelper.db();
    return db.query("data", where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(int id, String title, String? desc) async {
    final db = await DBHelper.db();
    final data = {
      "title": title,
      "desc": desc,
      "createdAt": DateTime.now().toString()
    };
    final result =
        await db.update("data", data, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await DBHelper.db();
    try {
      await db.delete("data", where: "id=?", whereArgs: [id]);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  static Future<int> checkData(int id) async {
    final db = await DBHelper.db();
    final data = {
      "is_done": "TRUE",
    };
    final result =
        await db.update("data", data, where: "id=?", whereArgs: [id]);
    return result;
  }

  static Future<int> unCheckData(int id) async {
    final db = await DBHelper.db();
    final data = {
      "is_done": "FALSE",
    };
    final result =
        await db.update("data", data, where: "id=?", whereArgs: [id]);
    return result;
  }
}
