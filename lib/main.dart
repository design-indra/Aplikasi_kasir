import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
  home: LoginPage(),
));

// --- 1. HALAMAN LOGIN ---
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final u = TextEditingController(); final p = TextEditingController();
  void _login() {
    if (u.text == 'admin' && p.text == '123') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardPage(role: 'Owner')));
    } else if (u.text == 'kasir' && p.text == '000') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardPage(role: 'Kasir')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Akses Ditolak!")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(padding: EdgeInsets.all(30), child: Column(children: [
          Icon(Icons.store_rounded, size: 100, color: Colors.indigo),
          Text("KASIR PRO HOLIS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 40),
          TextField(controller: u, decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder())),
          SizedBox(height: 15),
          TextField(controller: p, obscureText: true, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder())),
          SizedBox(height: 30),
          ElevatedButton(onPressed: _login, child: Text("LOGIN"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
        ])),
      ),
    );
  }
}

// --- 2. DASHBOARD ---
class DashboardPage extends StatelessWidget {
  final String role;
  DashboardPage({required this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard ($role)")),
      drawer: Drawer(
        child: ListView(children: [
          UserAccountsDrawerHeader(accountName: Text("Muhamad Holis"), accountEmail: Text(role), currentAccountPicture: CircleAvatar(child: Text(role[0]))),
          ListTile(leading: Icon(Icons.shopping_bag), title: Text("Kasir / Transaksi"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => KasirPage()))),
          if (role == 'Owner') ...[
            ListTile(leading: Icon(Icons.inventory_2), title: Text("Stok Barang"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProdukPage()))),
            ListTile(leading: Icon(Icons.analytics), title: Text("Laporan Penjualan"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => LaporanPage()))),
          ],
          Divider(),
          ListTile(leading: Icon(Icons.logout), title: Text("Keluar"), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginPage()))),
        ]),
      ),
      body: GridView.count(crossAxisCount: 2, padding: EdgeInsets.all(20), children: [
        _menuCard(context, "KASIR", Icons.shopping_cart, Colors.green, KasirPage()),
        if (role == 'Owner') _menuCard(context, "STOK", Icons.storage, Colors.orange, ProdukPage()),
        if (role == 'Owner') _menuCard(context, "LAPORAN", Icons.receipt_long, Colors.blue, LaporanPage()),
      ]),
    );
  }
  Widget _menuCard(context, String t, IconData i, Color c, Widget p) => Card(
    child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => p)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 50, color: c), Text(t)])),
  );
}

// --- 3. KASIR PRO ---
class KasirPage extends StatefulWidget {
  @override
  _KasirPageState createState() => _KasirPageState();
}
class _KasirPageState extends State<KasirPage> {
  final t = TextEditingController(); final d = TextEditingController(); String m = 'Tunai';
  void _bayar() async {
    double h = double.tryParse(t.text) ?? 0;
    double ds = double.tryParse(d.text) ?? 0;
    double total = h - (h * ds / 100);
    await DatabaseHelper.instance.simpanTransaksi(total, m, ds);
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("STRUK PEMBAYARAN"),
      content: Text("Harga: Rp $h\nDiskon: $ds%\nTotal: Rp $total\nMetode: $m"),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(c), child: Text("Selesai"))],
    ));
    t.clear(); d.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kasir Pro")),
      body: Padding(padding: EdgeInsets.all(20), child: Column(children: [
        TextField(controller: t, decoration: InputDecoration(labelText: "Total Harga Barang", border: OutlineInputBorder(), prefixText: "Rp "), keyboardType: TextInputType.number),
        SizedBox(height: 15),
        TextField(controller: d, decoration: InputDecoration(labelText: "Diskon (%)", border: OutlineInputBorder(), suffixText: "%"), keyboardType: TextInputType.number),
        SizedBox(height: 15),
        DropdownButtonFormField(value: m, items: ['Tunai', 'QRIS', 'Transfer'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => m = v!), decoration: InputDecoration(labelText: "Metode Bayar", border: OutlineInputBorder())),
        SizedBox(height: 30),
        ElevatedButton(onPressed: _bayar, child: Text("PROSES BAYAR"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60), backgroundColor: Colors.green, foregroundColor: Colors.white)),
      ])),
    );
  }
}

// --- 4. STOK BARANG ---
class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}
class _ProdukPageState extends State<ProdukPage> {
  List<Map<String, dynamic>> l = [];
  void _refresh() async { final data = await DatabaseHelper.instance.ambilSemuaProduk(); setState(() => l = data); }
  @override void initState() { super.initState(); _refresh(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manajemen Stok")),
      body: ListView.builder(itemCount: l.length, itemBuilder: (c, i) => ListTile(
        title: Text(l[i]['nama']), subtitle: Text("Rp ${l[i]['harga']} | Kategori: ${l[i]['kategori']}"),
        trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async { await DatabaseHelper.instance.hapusProduk(l[i]['id']); _refresh(); }),
      )),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: Icon(Icons.add)),
    );
  }
  void _add() {
    final n = TextEditingController(); final h = TextEditingController(); String k = 'Umum';
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, sState) => AlertDialog(
      title: Text("Tambah Barang"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: InputDecoration(labelText: "Nama")),
        TextField(controller: h, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
        DropdownButton<String>(value: k, isExpanded: true, items: ['Umum', 'Makanan', 'Minuman'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => sState(() => k = v!)),
      ]),
      actions: [ElevatedButton(onPressed: () async { await DatabaseHelper.instance.tambahProduk({'nama': n.text, 'harga': double.parse(h.text), 'stok': 99, 'kategori': k}); _refresh(); Navigator.pop(c); }, child: Text("Simpan"))],
    )));
  }
}

// --- 5. LAPORAN ---
class LaporanPage extends StatefulWidget {
  @override
  _LaporanPageState createState() => _LaporanPageState();
}
class _LaporanPageState extends State<LaporanPage> {
  List<Map<String, dynamic>> _lp = [];
  void _load() async { final d = await DatabaseHelper.instance.ambilLaporan(); setState(() => _lp = d); }
  @override void initState() { super.initState(); _load(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Laporan Penjualan")),
      body: ListView.builder(itemCount: _lp.length, itemBuilder: (c, i) => Card(child: ListTile(
        leading: Icon(Icons.receipt, color: Colors.indigo),
        title: Text("Total: Rp ${_lp[i]['total']}"),
        subtitle: Text("${_lp[i]['tanggal']} | ${_lp[i]['metode']}"),
        trailing: Text("-${_lp[i]['diskon']}%", style: TextStyle(color: Colors.red)),
      ))),
    );
  }
}
