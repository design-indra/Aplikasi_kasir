import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir_final.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE produk (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      nama TEXT, harga REAL, stok INTEGER, kategori TEXT)''');
    await db.execute('''CREATE TABLE penjualan (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      total REAL, tanggal TEXT, metode TEXT, diskon REAL)''');
  }

  Future<int> tambahProduk(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('produk', row);
  }

  Future<List<Map<String, dynamic>>> ambilSemuaProduk() async {
    final db = await instance.database;
    return await db.query('produk', orderBy: 'nama ASC');
  }

  Future<int> hapusProduk(int id) async {
    final db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> simpanTransaksi(double total, String metode, double diskon) async {
    final db = await instance.database;
    return await db.insert('penjualan', {
      'total': total,
      'metode': metode,
      'diskon': diskon,
      'tanggal': DateTime.now().toString().substring(0, 16)
    });
  }

  Future<List<Map<String, dynamic>>> ambilLaporan() async {
    final db = await instance.database;
    return await db.query('penjualan', orderBy: 'id DESC');
  }
}
