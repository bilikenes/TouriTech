import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rota_sayfasi.dart';
import 'widgets/yandan_acilir_menu.dart';

class NavigasyonSayfasi extends StatefulWidget {
  final Function(int)? onNavigate;
  const NavigasyonSayfasi({super.key, this.onNavigate});

  @override
  State<NavigasyonSayfasi> createState() => _NavigasyonSayfasiState();
}

class _NavigasyonSayfasiState extends State<NavigasyonSayfasi> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String? _currentAddress;
  LatLng? _searchedLocation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  // İstanbul'un koordinatları
  final LatLng _istanbul = const LatLng(41.0082, 28.9784);

  // API URL'si - kendi sunucu adresinizle değiştirin
  //String apiUrl = 'http://10.0.2.2:5000'; // Emülatör için localhost
  // Gerçek cihazda test ederken, sunucunuzun IP adresini kullanın
  String apiUrl = 'http://192.168.1.14:5000';
  //String apiUrl = 'http://192.168.152.218:5000';

  bool _rotaYukleniyor = false;
  Map<String, dynamic>? _rotaBilgileri;

  @override
  void initState() {
    super.initState();
    
    // Status bar'ın arka planını beyaz yap, simgeleri siyah yap
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // Simgeleri siyah yap
    ));
    
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    // Konum servisini başlat - ama haritayı hareket ettirme
    _checkLocationPermission();

    // API bağlantısını test et
    _testApiConnection();
  }

  @override
  void dispose() {
    // Sayfadan çıkarken varsayılan ayarlara geri dön
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Konum izni kontrolü
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Sadece konum bilgisini al, haritayı hareket ettirme
    _getCurrentLocationWithoutMovingMap();
  }

  // Mevcut konumu al ama haritayı hareket ettirme
  Future<void> _getCurrentLocationWithoutMovingMap() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentAddress = placemarks.isNotEmpty
            ? "${placemarks[0].street}, ${placemarks[0].locality}"
            : "Bilinmeyen Konum";
      });

      // Haritayı hareket ettirme kısmını kaldırdık
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  // Mevcut konumu al ve haritayı o konuma taşı (sadece butona basıldığında)
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentAddress = placemarks.isNotEmpty
            ? "${placemarks[0].street}, ${placemarks[0].locality}"
            : "Bilinmeyen Konum";
      });

      // Sadece butona basıldığında haritayı hareket ettir
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  // Arama yapma
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        setState(() {
          _searchedLocation =
              LatLng(locations[0].latitude, locations[0].longitude);
        });

        _mapController
            ?.animateCamera(CameraUpdate.newLatLngZoom(_searchedLocation!, 15));

        // Arama tamamlandığında doğrudan rota sayfasına yönlendir
        _rotaOlustur(_searchedLocation!, _searchController.text);
      }
    } catch (e) {
      print("Arama hatası: $e");
    }
  }

  // Konum bilgisini API'ye gönder ve rota bilgilerini al
  Future<void> _konumBilgisiniGonder(LatLng konum) async {
    setState(() {
      _rotaYukleniyor = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/rota-olustur'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enlem': konum.latitude,
          'boylam': konum.longitude,
        }),
      );

      setState(() {
        _rotaYukleniyor = false;
      });

      if (response.statusCode == 200) {
        final rotaBilgileri = jsonDecode(response.body);
        setState(() {
          _rotaBilgileri = rotaBilgileri;
        });

        print("Rota bilgileri alındı: ${rotaBilgileri.keys}");
        return rotaBilgileri;
      } else {
        throw Exception(
            'API isteği başarısız: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _rotaYukleniyor = false;
      });

      print("Konum bilgisi gönderme hatası: $e");
      return null;
    }
  }

  // API bağlantısını test et
  Future<void> _testApiConnection() async {
    try {
      // Daha uzun bir zaman aşımı süresi ekleyelim
      final response = await http.get(Uri.parse('$apiUrl/test'), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("API bağlantı testi: ${data['status']}");
      } else {
        throw Exception('API bağlantı testi başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print("API bağlantı testi hatası: $e");
    }
  }

  // Rota oluştur ve rota sayfasına yönlendir
  Future<void> _rotaOlustur(LatLng konum, String konumAdi) async {
    await _konumBilgisiniGonder(konum);

    if (_rotaBilgileri != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RotaSayfasi(
            startLocation: konumAdi,
            startCoordinates: konum,
            rotaBilgileri: _rotaBilgileri,
          ),
        ),
      );
    }
  }

  // Anlık konumu kullan
  void _useCurrentLocation() {
    if (_currentLocation != null) {
      _rotaOlustur(_currentLocation!, _currentAddress ?? 'Anlık Konumunuz');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // MediaQuery ile status bar yüksekliğini alalım
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F7F7),
      drawer: CustomDrawer(onNavigate: widget.onNavigate),
      // AppBar ekleyelim ve beyaz yapalım
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Sadece status bar'ı kaplamak için
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark, // Simgeleri siyah yap
          ),
        ),
      ),
      body: Stack(
        children: [
          // Harita
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _istanbul, // İstanbul'u göster
              zoom: 10, // Daha geniş açı için zoom değerini düşürdük
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // Başlangıçta hiçbir marker gösterme
            markers: {},
            // Yakınlaştırma kontrollerini kaldır
            zoomControlsEnabled: false,
          ),
          
          // Arama çubuğu benzeri üst kısım
          Positioned(
            top: 0, // Status bar artık AppBar tarafından yönetiliyor
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Color(0xFF112D4E),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 30,
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI TouriTech',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF112D4E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Arama kutusu
          Positioned(
            top: 80, // 60'tan 80'e çıkararak boşluğu artırdık
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(fontFamily: "Ubuntu", fontWeight: FontWeight.w300),
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Konum ara...',
                  
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchedLocation = null;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ),

          // Anlık konumu kullan butonu (arama kutusuna odaklanıldığında)
          if (_isSearchFocused)
            Positioned(
              top: 130, // Bu değeri de arama kutusunun yeni pozisyonuna göre ayarladık (80 + 50)
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.my_location),
                  title: const Text('Anlık konumunu kullan', style: TextStyle(fontFamily: "Ubuntu", fontWeight: FontWeight.w500)),
                  onTap: () {
                    _useCurrentLocation();
                    _searchFocusNode.unfocus();
                  },
                ),
              ),
            ),

            // Rota yükleniyor göstergesi
            if (_rotaYukleniyor)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'AI TouriTech sizin için en uygun rotayı oluşturuyor...',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Ubuntu", fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

            // Konum butonu
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),

            // Google Maps butonu (YENİ)
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: _openGoogleMaps,
                backgroundColor: Colors.white,
                child: const Icon(Icons.place, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // Google Maps uygulamasını açma fonksiyonu (Güncellendi)
  void _openGoogleMaps() async {
    // Onay kutusu göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.place, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text('Google Maps\'i Aç', style: TextStyle(fontFamily: "Ubuntu")),
            ],
          ),
          content: const Text(
            style: TextStyle(fontFamily: "Ubuntu"),
              'Google Maps uygulamasına yönlendirilmek istiyor musunuz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal', style: TextStyle(fontFamily:"Ubuntu",color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Google Maps\'i Aç', style: TextStyle(fontFamily: "Ubuntu")),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Mevcut konum varsa o konumu kullan, yoksa İstanbul'u kullan
                  final LatLng location = _currentLocation ?? _istanbul;

                  // Konum adını al
                  String locationName = "";

                  if (_currentLocation != null && _currentAddress != null) {
                    // Mevcut adres varsa kullan
                    locationName = _currentAddress!;
                  } else {
                    // Yoksa varsayılan bir değer kullan
                    locationName = "İstanbul";
                  }

                  // URL encode konum adı
                  final encodedName = Uri.encodeComponent(locationName);

                  // Google Maps URL şeması
                  final String googleMapsUrl =
                      'https://www.google.com/maps/search/?api=1&query=$encodedName';

                  print("Google Maps açılıyor: $googleMapsUrl");

                  // URL'yi aç
                  if (await canLaunch(googleMapsUrl)) {
                    await launch(googleMapsUrl);
                  } else {
                    throw 'Google Maps açılamadı';
                  }
                } catch (e) {
                  print("Google Maps açma hatası: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
