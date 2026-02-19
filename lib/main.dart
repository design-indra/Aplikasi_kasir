import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.deepPurple),
  home: LoginPage(), // Aplikasi dimulai dari halaman Login
));

// --- HALAMAN LOGIN ---
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void _login() {
    String user = userCtrl.text;
    String pass = passCtrl.text;

    if (user == 'admin' && pass == '123') {
      // Login sebagai Owner
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (c) => DashboardPage(role: 'Owner')
      ));
    } else if (user == 'kasir' && pass == '000') {
      // Login sebagai Kasir
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (c) => DashboardPage(role: 'Kasir')
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username atau Password Salah!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text("LOGIN KASIR HOLIS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder())),
              SizedBox(height: 15),
              TextField(controller: passCtrl, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _login,
                child: Text("MASUK"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- DASHBOARD DENGAN PEMBATASAN AKSES ---
class DashboardPage extends StatelessWidget {
  final String role;
  DashboardPage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard ($role)")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Muhamad Holis"),
              accountEmail: Text("Role: $role"),
              currentAccountPicture: CircleAvatar(child: Text(role[0])),
            ),
            // Menu Kasir (Bisa diakses semua role)
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Kasir"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => KasirPage())),
            ),
            
            // Menu Khusus Owner (Disembunyikan jika role bukan Owner)
            if (role == 'Owner') ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.inventory),
                title: Text("Manajemen Stok (Owner Only)"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ProdukPage())),
              ),
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text("Laporan Keuangan (Owner Only)"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => LaporanPage())),
              ),
            ],
            
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Keluar"),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginPage())),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selamat Datang, $role!", style: TextStyle(fontSize: 20)),
            if (role == 'Kasir') Padding(
              padding: EdgeInsets.all(20),
              child: Text("Gunakan menu Kasir untuk transaksi.", textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }
}

// Tambahkan KasirPage, ProdukPage, dan LaporanPage di bawah sini (gunakan kode sebelumnya)
class KasirPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Kasir"))); }
class ProdukPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Stok"))); }
class LaporanPage extends StatelessWidget { @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Laporan"))); }
