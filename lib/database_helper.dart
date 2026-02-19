import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir_super.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE produk (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, harga REAL, stok INTEGER, kategori TEXT, barcode TEXT)');
    await db.execute('CREATE TABLE penjualan (id INTEGER PRIMARY KEY AUTOINCREMENT, total REAL, tanggal TEXT, metode TEXT)');
  }

  // Tambah Produk
  Future<int> tambahProduk(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('produk', row);
  }

  // Ambil Semua Produk
  Future<List<Map<String, dynamic>>> ambilSemuaProduk() async {
    final db = await instance.database;
    return await db.query('produk');
  }

  // Transaksi & Kurangi Stok Otomatis
  Future simpanTransaksi(double total, String metode, List<Map<String, dynamic>> items) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Simpan data penjualan
      await txn.insert('penjualan', {
        'total': total,
        'tanggal': DateTime.now().toString().substring(0, 10),
        'metode': metode
      });
      // Kurangi stok masing-masing barang (simulasi)
      for (var item in items) {
        await txn.rawUpdate(
          'UPDATE produk SET stok = stok - 1 WHERE id = ?', [item['id']]
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> ambilLaporan() async {
    final db = await instance.database;
    return await db.query('penjualan', orderBy: 'id DESC');
  }
}
