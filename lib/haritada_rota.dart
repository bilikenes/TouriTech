import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';

class HaritadaRota extends StatefulWidget {
  final List<Map<String, dynamic>> selectedLocations;
  final String startLocation;
  final LatLng? startCoordinates;
  final Map<String, dynamic>? rotaBilgileri;
  final String activeRoute;
  final String? hedefAdi;

  const HaritadaRota({
    super.key,
    required this.selectedLocations,
    required this.startLocation,
    this.startCoordinates,
    this.rotaBilgileri,
    required this.activeRoute,
    this.hedefAdi,
  });

  @override
  State<HaritadaRota> createState() => _HaritadaRotaState();
}

class _HaritadaRotaState extends State<HaritadaRota> {
  late PageController _pageController;
  int _currentPage = 0;
  GoogleMapController? _mapController;
  bool _mapLoaded = false;

  // İstanbul'un koordinatları
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(41.0082, 28.9784),
    zoom: 12,
  );

  // Marker'lar için Map
  final Map<String, Marker> _markers = {};

  // Polyline'lar için Set
  final Set<Polyline> _polylines = {};

  // CSV'den yüklenen mekanlar
  Map<String, LatLng> _istanbulMekanlari = {};

  // Sınıf değişkenleri arasına ekleyin
  DateTime _startTime = DateTime.now(); // Başlangıç saati olarak şu anki zamanı kullan
  Map<int, String> _visitTimes = {}; // Her lokasyon için ziyaret saatlerini tutacak map

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);

    // CSV dosyasını yükle ve sonra marker'ları ekle
    _loadCsvData().then((_) {
      _addMarkersAndPolylines();
    });

    // Ziyaret saatlerini hesapla
    _calculateVisitTimes();

    // Tüm veriyi yazdır
    print("Başlangıç koordinatları: ${widget.startCoordinates}");
    print("Başlangıç konumu: ${widget.startLocation}");
    print("Aktif rota: ${widget.activeRoute}");
    print("Rota bilgileri: ${widget.rotaBilgileri}");
    print("Seçilen lokasyonlar: ${widget.selectedLocations}");
  }

  // CSV dosyasını yükle
  Future<void> _loadCsvData() async {
    try {
      final String csvData =
          await rootBundle.loadString('assets/istanbul_mekanlari.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvData);

      // CSV başlık satırını kontrol et
      if (csvTable.isNotEmpty) {
        // İlk satır başlık satırı olarak kabul edilir
        List<dynamic> headers = csvTable[0];
        int nameIndex = headers.indexOf('Mekan_Adi');
        int latIndex = headers.indexOf('Enlem');
        int lngIndex = headers.indexOf('Boylam');

        if (nameIndex >= 0 && latIndex >= 0 && lngIndex >= 0) {
          // Başlık satırını atla, diğer satırları işle
          for (int i = 1; i < csvTable.length; i++) {
            if (csvTable[i].length > nameIndex &&
                csvTable[i].length > latIndex &&
                csvTable[i].length > lngIndex) {
              String mekanAdi = csvTable[i][nameIndex].toString();
              double? lat = double.tryParse(csvTable[i][latIndex].toString());
              double? lng = double.tryParse(csvTable[i][lngIndex].toString());

              if (mekanAdi.isNotEmpty && lat != null && lng != null) {
                _istanbulMekanlari[mekanAdi.toLowerCase()] = LatLng(lat, lng);
                print("CSV'den yüklenen mekan: $mekanAdi - $lat, $lng");
              }
            }
          }
        } else {
          print("CSV başlık formatı uygun değil. Bulunan başlıklar: $headers");
          print("Aranan başlıklar: Mekan_Adi, Enlem, Boylam");
        }
      }

      print("CSV'den toplam ${_istanbulMekanlari.length} mekan yüklendi");
    } catch (e) {
      print("CSV yükleme hatası: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Marker'ları ve polyline'ları ekle
  void _addMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    // Başlangıç noktası
    LatLng startPosition =
        widget.startCoordinates ?? const LatLng(41.0054, 28.9768);

    // Başlangıç marker'ı
    _markers['start'] = Marker(
      markerId: const MarkerId('start'),
      position: startPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: "Başlangıç Noktası",
        snippet: widget.startLocation,
      ),
    );

    // Mekanlar için koordinatlar
    List<LatLng> routeCoordinates = [startPosition];

    // Her mekan için marker ekle
    for (int i = 0; i < widget.selectedLocations.length; i++) {
      final mekan = widget.selectedLocations[i];

      // Mekan adını al
      String mekanAdi = mekan['mekan_adi'] ?? mekan['name'] ?? 'Mekan ${i + 1}';

      // API'den gelen enlem ve boylam bilgilerini kullan
      double? lat = mekan['enlem'] != null
          ? double.tryParse(mekan['enlem'].toString())
          : null;
      double? lng = mekan['boylam'] != null
          ? double.tryParse(mekan['boylam'].toString())
          : null;

      // Eğer API'den koordinat geldiyse kullan, yoksa CSV'den bulmaya çalış
      LatLng position;
      if (lat != null && lng != null) {
        position = LatLng(lat, lng);
        print(
            "API'den alınan koordinatlar kullanılıyor: $mekanAdi - $lat, $lng");
      } else {
        position = _findCoordinatesFromCsv(mekanAdi, i);
        print("CSV'den bulunan koordinatlar kullanılıyor: $mekanAdi");
      }

      routeCoordinates.add(position);

      // Marker ekle
      _markers['location_$i'] = Marker(
        markerId: MarkerId('location_$i'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(i == _currentPage
            ? BitmapDescriptor.hueRed
            : BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: mekanAdi,
          snippet: mekan['ziyaret_suresi'] != null
              ? '${mekan['ziyaret_suresi']} dk'
              : mekan['time'] ?? '30 dk',
        ),
      );
    }

    // Polyline ekle
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routeCoordinates,
        color: Colors.blue,
        width: 3,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      ),
    );

    setState(() {});
  }

  // CSV'den mekan koordinatlarını bul
  LatLng _findCoordinatesFromCsv(String mekanAdi, int index) {
    // 1. Tam eşleşme kontrolü
    if (_istanbulMekanlari.containsKey(mekanAdi.toLowerCase())) {
      print("CSV'de tam eşleşme bulundu: $mekanAdi");
      return _istanbulMekanlari[mekanAdi.toLowerCase()]!;
    }

    // 2. Kısmi eşleşme kontrolü
    for (var entry in _istanbulMekanlari.entries) {
      if (entry.key.contains(mekanAdi.toLowerCase()) ||
          mekanAdi.toLowerCase().contains(entry.key)) {
        print("CSV'de kısmi eşleşme bulundu: $mekanAdi - ${entry.key}");
        return entry.value;
      }
    }

    // 3. Kelime bazlı eşleşme kontrolü
    List<String> mekanKelimeleri = mekanAdi.toLowerCase().split(' ');
    for (var kelime in mekanKelimeleri) {
      if (kelime.length > 3) {
        // Çok kısa kelimeleri atla
        for (var entry in _istanbulMekanlari.entries) {
          if (entry.key.contains(kelime)) {
            print(
                "CSV'de kelime bazlı eşleşme bulundu: $mekanAdi - ${entry.key} (kelime: $kelime)");
            return entry.value;
          }
        }
      }
    }

    // 4. Eşleşme bulunamazsa İstanbul'un merkezinde bir konum
    print(
        "CSV'de eşleşme bulunamadı: $mekanAdi, İstanbul merkezi kullanılıyor");
    return LatLng(41.0082 + (index * 0.005), 28.9784 + (index * 0.005));
  }

  // Haritayı belirli bir lokasyona odakla
  void _centerMapOnLocation(int index) {
    if (_mapController == null || widget.selectedLocations.isEmpty) return;

    final mekan = widget.selectedLocations[index];

    // API'den gelen enlem ve boylam bilgilerini kullan
    double? lat = mekan['enlem'] != null
        ? double.tryParse(mekan['enlem'].toString())
        : null;
    double? lng = mekan['boylam'] != null
        ? double.tryParse(mekan['boylam'].toString())
        : null;

    LatLng position;
    if (lat != null && lng != null) {
      position = LatLng(lat, lng);
    } else {
      String mekanAdi =
          mekan['mekan_adi'] ?? mekan['name'] ?? 'Mekan ${index + 1}';
      position = _findCoordinatesFromCsv(mekanAdi, index);
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(position, 15),
    );

    setState(() {
      _currentPage = index;
      _addMarkersAndPolylines();
    });
  }

  // Ziyaret saatlerini hesaplayan metod
  void _calculateVisitTimes() {
    DateTime currentTime = _startTime;
    
    for (int i = 0; i < widget.selectedLocations.length; i++) {
      final location = widget.selectedLocations[i];
      
      // Ziyaret süresini al (dakika cinsinden)
      int visitDuration = 30; // Varsayılan süre
      if (location['ziyaret_suresi'] != null) {
        visitDuration = int.tryParse(location['ziyaret_suresi'].toString()) ?? 30;
      } else if (location['time'] != null) {
        String timeStr = location['time'].toString();
        visitDuration = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      }
      
      // Lokasyon için başlangıç ve bitiş saatlerini hesapla
      String startTimeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      
      // Bitiş saatini hesapla
      DateTime endTime = currentTime.add(Duration(minutes: visitDuration));
      String endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      
      // Ziyaret saatini kaydet
      _visitTimes[i] = '$startTimeStr - $endTimeStr';
      
      // Bir sonraki lokasyon için başlangıç saatini güncelle
      // Ziyaret süresi + yolda geçen süre (varsayılan 15 dakika)
      currentTime = endTime.add(const Duration(minutes: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Doğrudan Scaffold döndürüyoruz, alt bar olmadan
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota Haritası', style: TextStyle(fontFamily: 'Ubuntu')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              setState(() {
                _mapLoaded = true;
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Google Maps butonu (YENİ)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _openGoogleMaps,
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.place, color: Colors.red),
            ),
          ),

          // Alt kısımdaki kayan kartlar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.selectedLocations.length,
              onPageChanged: (int page) {
                _centerMapOnLocation(page);
              },
              itemBuilder: (context, index) {
                final location = widget.selectedLocations[index];
                return _buildLocationCard(location, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location, int index) {
    // API'den gelen veri formatına göre kart oluştur
    String name = location['mekan_adi'] ?? location['name'] ?? 'Mekan ${index + 1}';
    String time = _visitTimes[index] ?? '10:00 - 12:00'; // Hesaplanan ziyaret saati
    
    // Yıldız sayısını ve değerlendirme sayısını al (varsa)
    double rating = 5.0; // Varsayılan değer
    if (location['rating'] != null) {
      rating = double.tryParse(location['rating'].toString()) ?? 5.0;
    }
    
    String reviewCount = location['review_count'] != null 
        ? '${location['review_count']} değerlendirme' 
        : '67.212 değerlendirme'; // Varsayılan değer

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Lokasyon numarası ve adı
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lokasyon numarası (mavi daire içinde)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Lokasyon adı
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Yıldız derecelendirmesi
            Row(
              children: [
                // 5 yıldız göster
                for (int i = 0; i < 5; i++)
                  Icon(
                    Icons.star,
                    color: i < rating.floor() ? Colors.amber : Colors.grey,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                // Değerlendirme sayısı
                Text(
                  reviewCount,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Ziyaret saati
            Row(
              children: [
                const Icon(Icons.access_time_filled, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Yol tarifi butonu - Güncellendi
                TextButton(
                  onPressed: () {
                    _openGoogleMapsDirections(index);
                  },
                  child: const Text(
                    'Yol Tarifi',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
              const Text('Google Maps\'i Aç', style: TextStyle(fontFamily: 'Ubuntu')),
            ],
          ),
          content: const Text(
              'Google Maps uygulamasına yönlendirilmek istiyor musunuz?',
              style: TextStyle(fontFamily: 'Ubuntu')),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal', style: TextStyle(fontFamily: 'Ubuntu', color: Colors.grey)),
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
              child: const Text('Google Maps\'i Aç', style: TextStyle(fontFamily: 'Ubuntu')),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Başlangıç konumunu al
                  LatLng startPosition =
                      widget.startCoordinates ?? const LatLng(41.0054, 28.9768);
                  String locationName = widget.startLocation;

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google Maps açılamadı: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Yol tarifi için Google Maps'i açma fonksiyonu (YENİ)
  void _openGoogleMapsDirections(int locationIndex) async {
    try {
      // Seçilen lokasyonu al
      final location = widget.selectedLocations[locationIndex];
      String locationName = location['mekan_adi'] ?? location['name'] ?? 'Mekan ${locationIndex + 1}';
      
      // Koordinatları al
      double? lat = location['enlem'] != null
          ? double.tryParse(location['enlem'].toString())
          : null;
      double? lng = location['boylam'] != null
          ? double.tryParse(location['boylam'].toString())
          : null;
      
      // Koordinatlar yoksa CSV'den bul
      LatLng destination;
      if (lat != null && lng != null) {
        destination = LatLng(lat, lng);
      } else {
        destination = _findCoordinatesFromCsv(locationName, locationIndex);
      }
      
      // Google Maps yol tarifi URL'si
      final String googleMapsUrl = 
          'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&destination_place_id=&travelmode=driving';
      
      print("Google Maps yol tarifi açılıyor: $googleMapsUrl");
      
      // URL'yi aç
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Google Maps açılamadı';
      }
    } catch (e) {
      print("Google Maps yol tarifi hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Maps yol tarifi açılamadı: $e')),
      );
    }
  }
}
