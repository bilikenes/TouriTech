import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'haritada_rota.dart'; // HaritadaRota widget'ını import ediyoruz

class RotaSayfasi extends StatefulWidget {
  final String startLocation;
  final LatLng? startCoordinates;
  final Map<String, dynamic>? rotaBilgileri;

  const RotaSayfasi({
    Key? key,
    required this.startLocation,
    this.startCoordinates,
    this.rotaBilgileri,
  }) : super(key: key);

  @override
  State<RotaSayfasi> createState() => _RotaSayfasiState();
}

class _RotaSayfasiState extends State<RotaSayfasi> {
  bool _isAlternativeRoute = false;

  // Aktif rota için kullanılacak liste
  List<Map<String, dynamic>> _activeLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeRoutes();
  }

  void _initializeRoutes() {
    if (widget.rotaBilgileri != null) {
      // Python API'sinden gelen rotaları kullan
      setState(() {
        _activeLocations = List<Map<String, dynamic>>.from(_isAlternativeRoute
            ? widget.rotaBilgileri!['alternatif_rota']
            : widget.rotaBilgileri!['ilk_rota']);
      });
    } else {
      // Rota bilgisi yoksa boş liste kullan
      setState(() {
        _activeLocations = [];
      });
    }
  }

  // Rota değiştirme fonksiyonu
  void _toggleRoute() {
    setState(() {
      _isAlternativeRoute = !_isAlternativeRoute;
      if (widget.rotaBilgileri != null) {
        _activeLocations = List<Map<String, dynamic>>.from(_isAlternativeRoute
            ? widget.rotaBilgileri!['alternatif_rota']
            : widget.rotaBilgileri!['ilk_rota']);
      }
    });
  }

  // Harita görünümüne geçiş
  void _navigateToMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HaritadaRota(
          selectedLocations: _activeLocations,
          startLocation: widget.startLocation,
          startCoordinates: widget.startCoordinates,
          rotaBilgileri: widget.rotaBilgileri,
          activeRoute: _isAlternativeRoute ? 'alternatif_rota' : 'ilk_rota',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Önerilen Rota', style: TextStyle(fontFamily: 'Ubuntu')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              // Rota Listesi
              Expanded(
                child: _buildRotaListesi(),
              ),

              // Alt butonlar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Alternatif Rota Butonu
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: _toggleRoute,
                        icon: const Icon(Icons.swap_horiz),
                        label: Text(
                          _isAlternativeRoute ? 'İlk Rotaya Dön' : 'Alternatif Rota',
                          style: const TextStyle(fontFamily: 'Ubuntu'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Rotayı Onayla Butonu
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToMapView,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Rotayı Onayla', style: TextStyle(fontFamily: 'Ubuntu')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotaListesi() {
    // Tüm lokasyonları ve aralarındaki bağlantıları içeren bir liste oluşturalım
    final List<Widget> allItems = [];

    // Başlangıç konumu kartını ekle
    allItems.add(
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Başlangıç Konumu',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.startLocation,
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_downward,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );

    // Tüm lokasyonları ve aralarındaki bağlantıları ekle
    for (int i = 0; i < _activeLocations.length; i++) {
      // Bağlantı çizgisi ve mesafe bilgisi
      final mekan = _activeLocations[i];
      // Seyahat süresini tam sayıya yuvarla
      final seyahatSuresi = mekan['seyahat_suresi'].round().toString();
      final ulasimModu = mekan['ulasimModu'];

      allItems.add(
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Kesikli çizgi
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  size: const Size(1, 60),
                  painter: DashedLinePainter(),
                ),
              ),
              // Mesafe bilgisi
              Positioned(
                left: 30,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTransportIcon(ulasimModu),
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$seyahatSuresi dk',
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Lokasyon kartı
      allItems.add(
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mekan['ziyaret_suresi']} dk ziyaret',
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mekan['mekan_adi'],
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            mekan['kategori'],
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.blue,
                ),
              ],
            ),
            onTap: () {
              // Mekan detaylarını göster
            },
          ),
        ),
      );
    }

    // Tüm öğeleri bir ListView içinde döndür
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: allItems,
    );
  }

  // Ulaşım moduna göre ikon seçme
  IconData _getTransportIcon(String ulasimModu) {
    switch (ulasimModu.toLowerCase()) {
      case 'yürüyüş':
        return Icons.directions_walk;
      case 'toplu taşıma':
        return Icons.directions_bus;
      case 'araba':
        return Icons.directions_car;
      case 'bisiklet':
        return Icons.directions_bike;
      default:
        return Icons.directions;
    }
  }
}

// Kesikli çizgi çizmek için özel bir painter sınıfı
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      // Bir çizgi çiz
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      // Bir sonraki çizgi için ilerle
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
