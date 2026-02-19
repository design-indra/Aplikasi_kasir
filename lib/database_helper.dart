import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE produk (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nama TEXT NOT NULL,
  harga REAL NOT NULL,
  stok INTEGER NOT NULL
)
''');
  }

  Future<int> tambahProduk(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('produk', row);
  }

  Future<List<Map<String, dynamic>>> ambilSemuaProduk() async {
    final db = await instance.database;
    return await db.query('produk');
  }
}
