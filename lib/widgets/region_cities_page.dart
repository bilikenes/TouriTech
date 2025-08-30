import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../city.dart'; // City modelini içe aktarıyoruz
import 'package:flutter_app_0/services/favorites_service.dart'; // FavoritesService'i import ediyoruz

//List<bool> isFavoriteNearby = List.filled(6, false);

class RegionCitiesPage extends StatefulWidget {
  final String regionName;

  RegionCitiesPage({required this.regionName});

  @override
  _RegionCitiesPageState createState() => _RegionCitiesPageState();
}

class _RegionCitiesPageState extends State<RegionCitiesPage> {
  List<City> _cities = [];
  Set<String> _favoriteCities = {}; // Favori şehirlerin listesi
  final TextEditingController _aramaController = TextEditingController();
  String _searchQuery = '';
  final FavoritesService _favoritesService = FavoritesService(); // FavoritesService instance'ı

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadFavorites(); // Favorileri yükle
  }

  Future<void> _loadCities() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/provinces.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<City> cities = (jsonData['data'] as List)
          .where((item) => item['region']?['tr'] == widget.regionName)
          .map((item) => City.fromJson(item))
          .toList();

      setState(() {
        _cities = cities;
      });
    } catch (e) {
      print("Error loading cities: $e");
    }
  }

  void _filterCities(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _showCityInfoDialog(BuildContext context, City city) {
    showDialog(
      context: context,
      builder: (context) {
        // Ekran genişliğini alıyoruz
        double screenWidth = MediaQuery.of(context).size.width;

        // Dialog genişliğini ekranın %80'i kadar belirliyoruz
        double dialogWidth = screenWidth * 0.8;

        // 4:3 oranına göre yüksekliği hesaplıyoruz
        double dialogHeight = dialogWidth * 3 / 4;

        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25), // Popup tamamen yuvarlatıldı
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        image: DecorationImage(
                          image: AssetImage(city.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ' ${city.description}', // Başta bir boşluk ekledik
                        style: TextStyle(fontFamily: 'Ubuntu'),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Yakındaki Yerler",
                        style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.hotel,
                                      color: const Color.fromARGB(
                                          255, 21, 32, 41)),
                                  SizedBox(width: 5),
                                  Text("Otel", style: TextStyle(fontFamily: 'Ubuntu')),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 100),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.restaurant,
                                      color: const Color.fromARGB(
                                          255, 21, 32, 41)),
                                  SizedBox(width: 5),
                                  Text("Yemek", style: TextStyle(fontFamily: 'Ubuntu')),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          child: Text("Hadi Gidelim", style: TextStyle(fontFamily: 'Ubuntu')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _loadFavorites() {
    _favoritesService.getFavorites().listen((favorites) {
      setState(() {
        _favoriteCities = Set.from(favorites.map((fav) => fav['title'] as String));
      });
    });
  }

  void _toggleFavorite(String cityName) {
    setState(() {
      if (_favoriteCities.contains(cityName)) {
        _favoriteCities.remove(cityName);
        _favoritesService.removeFromFavorites(cityName); // Favorilerden kaldır
      } else {
        _favoriteCities.add(cityName);
        // Şehrin resmini bul
        City city = _cities.firstWhere((city) => city.name == cityName);
        _favoritesService.addToFavorites(city.image, cityName); // Favorilere ekle
      }
    });
  }

  Widget _buildImage(String imagePath, String name, double width) {
    bool isFavorite = _favoriteCities.contains(name);
    double newSize = width * 1.2; // Resimleri %20 büyüt

    return GestureDetector(
      onTap: () {
        City city = _cities.firstWhere((city) => city.name == name);
        _showCityInfoDialog(context, city);
      },
      child: Container(
        width: newSize, // Artırılmış genişlik
        height: newSize, // Artırılmış yükseklik
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color.fromARGB(173, 0, 0, 0),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // Favori butonu - sağ üste taşındı
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  _toggleFavorite(name);
                },
              ),
            ),
            // Şehir adı - alt kısımda kaldı
            Positioned(
              left: 10,
              bottom: 10,
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<City> filteredCities = _cities
        .where((city) => city.name.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.regionName + " Bölgesi", style: TextStyle(fontFamily: 'Ubuntu')),
        backgroundColor: Color(0xFFF9F7F7),
      ),
      backgroundColor: Color(0xFFF9F7F7),
      body: _cities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _aramaController,
                    onChanged: _filterCities,
                    style: TextStyle(fontFamily: 'Ubuntu'),
                    decoration: InputDecoration(
                      hintText: 'Arama yapın...',
                      hintStyle: TextStyle(
                          fontFamily: "Ubuntu", color: Color(0xFF112D4E)),
                      // Arama yapın... yazısının rengi
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF112D4E)),
                      // büyüteç ikonu rengi
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF112D4E)),
                        // x ikonunun rengi
                        onPressed: () {
                          _aramaController.clear();
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFDBE2EF),
                      // arama çubuğu arkaplan rengi
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[500]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      // Sol ve sağ boşluk eklendi
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Arama çubuğu ile resimler arasına boşluk ekledik
                Expanded(
                  child: ListView.builder(
                    itemCount: (filteredCities.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final firstCity = filteredCities[index * 2];
                      final secondCity = index * 2 + 1 < filteredCities.length
                          ? filteredCities[index * 2 + 1]
                          : null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5), // şehirler arasındaki beyaz boşluk
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildImage(firstCity.image, firstCity.name, 150),
                              if (secondCity != null)
                                _buildImage(
                                    secondCity.image, secondCity.name, 150),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}