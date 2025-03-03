import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/research_data.dart';

class DBHelper {
  static Database? _database;
  static const int _dbVersion = 6; // ✅ อัปเดตเป็นเวอร์ชันใหม่

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'research.db');
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE research_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          title TEXT,
          description TEXT,
          inventor TEXT,
          imagePath TEXT,
          date TEXT -- ✅ เพิ่มคอลัมน์ date
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          try {
            // ✅ เพิ่มคอลัมน์ date ถ้ายังไม่มี
            await db.execute(
              'ALTER TABLE research_data ADD COLUMN date TEXT DEFAULT ""',
            );
          } catch (e) {
            print("⚠️ Column 'date' already exists or error: $e");
          }
        }
      },
    );
  }

  // ✅ ฟังก์ชันเพิ่มข้อมูล
  static Future<int> insertData(ResearchData data) async {
    final db = await database;
    return await db.insert('research_data', data.toMap());
  }

  // ✅ ฟังก์ชันอัปเดตข้อมูล
  static Future<int> updateData(ResearchData data) async {
    final db = await database;
    return await db.update(
      'research_data',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  static Future<int> deleteData(int id) async {
    final db = await database;
    return await db.delete('research_data', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<ResearchData>> getDataByCategory(String category) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'research_data',
      where: 'category = ?',
      whereArgs: [category],
    );
    return maps.map((m) => ResearchData.fromMap(m)).toList();
  }
}
