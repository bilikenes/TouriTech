import 'package:flutter/material.dart';
import '../ana_sayfa.dart'; // diğer sayfaları da aynı şekilde import edin
import '../navigasyon_sayfasi.dart';
import '../qr.dart';
import '../profil_sayfasi.dart';
import '../favoriler_sayfasi.dart';
// bu dosyayı main.dart dosyasına import ederseniz her yerde gözükür.
// ayrı ayrı her dosyaya import etmeyin. main.dart dosyasında olsun sadece

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // alt bardaki butonlara basınca sayfa açılması kısmı buradan çağırılacak.
    const Home(),
    const NavigasyonSayfasi(),
    QRPage(),
    Favoriler(onNavigate: (index) {}), // Başlangıçta boş bir fonksiyon veriyoruz
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // _screens listesini initState içinde güncelliyoruz
    _screens[3] = Favoriler(onNavigate: _onItemTapped);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        // alt bar
        children: [
          BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, // ana sayfa ikonu buradan değişir
                    size: 30, // ikon boyutu
                    color: _selectedIndex == 0 // ana sayfanın indexi 0
                        ? const Color(0xFF3F72AF) // üstüne basıldığındaki renk
                        : const Color(0xFF112D4E)), // normal renk
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                    Icons.bus_alert, // rota oluşturma ikonu buradan değişir
                    size: 30, // ikon boyutu
                    color: _selectedIndex == 1 // rota sayfasının indexi 1
                        ? const Color(0xFF3F72AF) // üstüne basıldığındaki renk
                        : const Color(0xFF112D4E)), // normal renk
                label: 'Keşfet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner, // qr kod sayfası ikonu
                    size: 30, // ikon boyutu
                    color: _selectedIndex == 2 // qr kod sayfasının indexi 2
                        ? const Color(0xFF3F72AF) // üstüne basıldığındaki renk
                        : const Color(0xFF112D4E)), // normal renk
                label: 'QR Kod',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, // favoriler sayfası ikonu
                    size: 30, // ikon boyutu
                    color: _selectedIndex == 3 // favoriler sayfasının indexi 3
                        ? const Color(0xFF3F72AF) // üstüne basıldığındaki renk
                        : const Color(0xFF112D4E)), // normal renk
                label: 'Favoriler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, // profil sayfası ikonu
                    size: 30, // ikon boyutu
                    color: _selectedIndex == 4 // profil sayfasının indexi 4
                        ? const Color(0xFF3F72AF) // üstüne basıldığındaki renk
                        : const Color(0xFF112D4E)), // normal renk
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            showSelectedLabels:
                false, // true olursa ikonların altında sayfa adı yazar
            showUnselectedLabels:
                false, // bu da aynı şekilde (default olarak true geliyor bunlar)
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFF9F7F7), // alt bar arkaplan rengi
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
