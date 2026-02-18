import 'package:flutter/material.dart';
import 'database_helper.dart'; // Menghubungkan ke brankas data

void main() => runApp(MaterialApp(
      home: KasirHolisHome(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    ));

// --- HALAMAN UTAMA (DAFTAR STOK) ---
class KasirHolisHome extends StatefulWidget {
  @override
  _KasirHolisHomeState createState() => _KasirHolisHomeState();
}

class _KasirHolisHomeState extends State<KasirHolisHome> {
  List<Map<String, dynamic>> _daftarProduk = [];

  @override
  void initState() {
    super.initState();
    _muatData(); // Ambil data saat aplikasi dibuka
  }

  // Fungsi untuk mengambil data dari Database
  Future<void> _muatData() async {
    final data = await DatabaseHelper.instance.ambilSemuaProduk();
    setState(() {
      _daftarProduk = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kasir Pro - Muhamad Holis")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Muhamad Holis"),
              accountEmail: Text("Lead Developer"),
              currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text("MH")),
            ),
            ListTile(leading: Icon(Icons.info), title: Text("Versi Aplikasi 1.0.0")),
          ],
        ),
      ),
      body: _daftarProduk.isEmpty
          ? Center(child: Text("Belum ada produk. Tambahkan di tombol +"))
          : ListView.builder(
              itemCount: _daftarProduk.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(_daftarProduk[index]['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Harga: Rp ${_daftarProduk[index]['harga']} | Stok: ${_daftarProduk[index]['stok']}"),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Pindah ke halaman tambah, lalu muat ulang data saat kembali
          await Navigator.push(context, MaterialPageRoute(builder: (context) => HalamanTambahHolis()));
          _muatData();
        },
      ),
    );
  }
}

// --- HALAMAN TAMBAH PRODUK ---
class HalamanTambahHolis extends StatefulWidget {
  @override
  _HalamanTambahHolisState createState() => _HalamanTambahHolisState();
}

class _HalamanTambahHolisState extends State<HalamanTambahHolis> {
  // Controller untuk menangkap ketikan Holis
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  Future<void> _simpanKeDatabase() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mohon isi semua kolom!")));
      return;
    }

    // Memasukkan data ke Database (Brankas)
    await DatabaseHelper.instance.tambahProduk({
      'nama': _namaController.text,
      'harga': int.parse(_hargaController.text),
      'stok': int.parse(_stokController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Produk ${_namaController.text} Berhasil Disimpan!")),
    );

    Navigator.pop(context); // Kembali ke halaman utama
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Produk Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _namaController, decoration: InputDecoration(labelText: "Nama Barang")),
            TextField(controller: _hargaController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: _stokController, decoration: InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _simpanKeDatabase, // Ini proses "Menghubungkan Tombol"
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Center(child: Text("SIMPAN DATA")),
              ),
            ),
            SizedBox(height: 20),
            Text("Dikembangkan oleh: Muhamad Holis", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
