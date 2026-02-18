import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Membuat instance tunggal agar hemat memori
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Mengecek apakah database sudah ada, jika belum maka buat baru
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kasir_muhamad_holis.db');
    return _database!;
  }

  // Menginisialisasi lokasi penyimpanan di HP
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB
    );
  }

  // Membuat tabel untuk menyimpan Nama Barang, Harga, dan Stok
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        harga INTEGER NOT NULL,
        stok INTEGER NOT NULL
      )
    ''');
  }

  // Fungsi untuk Menambah Produk (Dipakai tombol Simpan)
  Future<int> tambahProduk(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('produk', row);
  }

  // Fungsi untuk Menampilkan Semua Produk ke Layar
  Future<List<Map<String, dynamic>>> ambilSemuaProduk() async {
    final db = await instance.database;
    return await db.query('produk', orderBy: 'id DESC');
  }

  // Fungsi opsional: Menghapus Produk
  Future<int> hapusProduk(int id) async {
    final db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }
}
