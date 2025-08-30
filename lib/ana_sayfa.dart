import 'package:flutter/material.dart';
import 'package:flutter_app_0/widgets/yandan_acilir_menu.dart';
import 'package:flutter_app_0/widgets/region_cities_page.dart';
import 'dart:async';
import 'package:flutter_app_0/services/favorites_service.dart';

FavoritesService _favoritesService = FavoritesService();

class Home extends StatefulWidget {
  final Function(int)? onNavigate;

  const Home({super.key, this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

List<bool> isFavoriteList = List.filled(6, false); // 6 öğe için favori durumu
List<bool> isFavoriteNearby = List.filled(6, false);

class _HomeState extends State<Home> {
  final TextEditingController _aramaController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(viewportFraction: 0.9);

  Timer? _timer;
  @override
  @override
  void initState() {
    // Bu fonksiyon otomatik kayan slider'ın geçiş süresini azaltır.
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients) {
        if (_pageController.page?.round() == 5) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _aramaController.dispose();
    super.dispose();
  }

  void _popup(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            constraints: BoxConstraints(
              minHeight: 450, // Popup boyu biraz kısa tutuldu
              maxHeight: 500,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Tüm köşeler oval
            ),
            child: Stack(
              children: [
                // GÖRSELİ BEYAZ ALANIN ARKASINA UZAT
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 200, // Görsel biraz daha uzun
                    fit: BoxFit.cover,
                  ),
                ),
                // ALT BEYAZ ALAN
                Positioned(
                  top: 170, // Görselin biraz arkasına gelsin
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20), // Sol alt köşe oval
                        bottomRight: Radius.circular(20), // Sağ alt köşe oval
                        topLeft: Radius.circular(20), // Üst sol köşe oval
                        topRight: Radius.circular(20), // Üst sağ köşe oval
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(), // Görselle çakışmaması için boşluk
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Açıklama yok",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        SizedBox(height: 40),
                        Text(
                          "Yakındaki Yerler",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.hotel,
                                    color: Colors.black87, size: 20),
                                SizedBox(width: 6),
                                Text("Otel", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.restaurant,
                                    color: Colors.black87, size: 20),
                                SizedBox(width: 6),
                                Text("Yemek", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  Size(100, 50), // Genişlik: 200, Yükseklik: 50
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12), // İç boşluk
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Köşeleri yuvarlama
                              ),
                            ),
                            child: Text(
                              "Hadi Gidelim",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ÇIKIŞ BUTONU (Sağ üst köşe)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRouteSuggestions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba sevgili kullanıcı,\n\nBen RoboKeşif. Sana güzel bir deneyim yaşatmak için gezi rotası önerim var. Aşağıdaki butona tıklayarak başlatabilirsin.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Gezi Rotaları:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildRouteItem(
                      title: 'Sultan Ahmet',
                      imageUrl: 'assets/images/populer_yerler/sultan_ahmet.jpg',
                      duration: '2 Saat',
                    ),
                    SizedBox(height: 10),
                    _buildRouteItem(
                      title: 'Galata Kulesi',
                      imageUrl: 'assets/images/populer_yerler/galata_kulesi.jpg',
                      duration: '1.5 Saat',
                    ),
                    SizedBox(height: 10),
                    _buildRouteItem(
                      title: 'Kız Kulesi',
                      imageUrl: 'assets/images/populer_yerler/kiz_kulesi.jpg',
                      duration: '1 Saat',
                    ),
                    SizedBox(height: 10),
                    _buildRouteItem(
                      title: 'Restoran',
                      imageUrl: 'assets/doga.jpg',
                      duration: '1 Saat',
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Geziyi Başlat'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Alternatif Rota Öner'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _searchQuery = '';

  void _filterRegions(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight =
        MediaQuery.of(context).size.height; // cihaz yüksekliği
    double deviceWidth = MediaQuery.of(context).size.width; // cihaz genişliği
    
    // Check if search is active
    bool isSearchActive = _searchQuery.isNotEmpty;
    
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF9F7F7), // sayfanın arka plan rengi
        key: _scaffoldKey,
        drawer: CustomDrawer(onNavigate: widget.onNavigate),
        body: Column(
          children: [
            // Arama çubuğu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      // yandaki menü için buton
                      Icons.menu,
                      color: Color(0xFF112D4E),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 30,
                    onPressed: () {
                      // basıldığında açılır menüyü açar
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(
                      width: 8), // İkon ile arama çubuğu arası boşluk
                  Expanded(
                    child: TextField(
                      controller: _aramaController,
                      onChanged: _filterRegions,
                      style: TextStyle(fontFamily: 'Ubuntu'),
                      decoration: InputDecoration(
                        hintText: 'Arama yapın...',
                        hintStyle: TextStyle(fontFamily: 'Ubuntu', color: Color(0xFF112D4E)),
                        // Arama yapın... yazısının rengi
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF112D4E)),
                        // büyüteç ikonu rengi
                        suffixIcon: IconButton(
                          icon:
                              const Icon(Icons.clear, color: Color(0xFF112D4E)),
                          // x ikonunun rengi
                          onPressed: () {
                            _aramaController.clear();
                            _filterRegions(''); // Clear search results
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only show Popüler Yerler if not searching
                    if (!isSearchActive) ...[
                      // İlk slider (Popüler Yerler)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          'Popüler Yerler',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: 6,
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            // Resim listesi
                            final List<String> images = [
                              'assets/images/populer_yerler/kapadokya.jpg',
                              'assets/images/populer_yerler/istanbul.jpg',
                              'assets/images/populer_yerler/oludeniz.jpg',
                              'assets/images/populer_yerler/pamukkale.jpg',
                              'assets/images/populer_yerler/efes.jpg',
                              'assets/images/populer_yerler/nemrut.jpg',
                            ];

                            // Başlık listesi
                            final List<String> titles = [
                              'Kapadokya',
                              'İstanbul',
                              'Ölüdeniz',
                              'Pamukkale',
                              'Efes Antik Kenti',
                              'Nemrut Dağı',
                            ];

                            return GestureDetector(
                              onTap: () {
                                _popup(context, images[index], titles[index]);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            const Color.fromARGB(178, 0, 0, 0),
                                          ],
                                          stops: const [0.6, 1.0],
                                        ),
                                      ),
                                    ),
                                    // resmin üstündeki yazı
                                    Positioned(
                                      left: 16,
                                      bottom: 12,
                                      child: Text(
                                        titles[index],
                                        style: const TextStyle(
                                          fontFamily: 'Ubuntu',
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isFavoriteList[index] =
                                                !isFavoriteList[index];
                                            if (isFavoriteList[index]) {
                                              _favoritesService.addToFavorites(
                                                  images[index], titles[index]);
                                            } else {
                                              _favoritesService
                                                  .removeFromFavorites(
                                                      titles[index]);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isFavoriteList[index]
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavoriteList[index]
                                              ? Colors.red
                                              : Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // İkinci slider (Yakınımdaki Yerler)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 24),
                        child: Text(
                          'Yakınımdaki Yerler',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: 6,
                          controller: PageController(viewportFraction: 0.9),
                          itemBuilder: (context, index) {
                            // Resim listesi
                            final List<String> images = [
                              'assets/images/yakinimdaki_yerler/ayasofya.jpg',
                              'assets/images/yakinimdaki_yerler/dolmabahce.jpg',
                              'assets/images/yakinimdaki_yerler/galata_kulesi.jpg',
                              'assets/images/yakinimdaki_yerler/ortakoy_camii.jpg',
                              'assets/images/yakinimdaki_yerler/yerebatan.jpg',
                              'assets/images/yakinimdaki_yerler/istiklal_caddesi.jpg',
                            ];

                            // Başlık listesi
                            final List<String> titles = [
                              'Ayasofya',
                              'Dolmabahçe Sarayı',
                              'Galata Kulesi',
                              'Ortaköy Camii',
                              'Yerebatan Sarnıcı',
                              'İstiklal Caddesi',
                            ];
                            return GestureDetector(
                              onTap: () {
                                _popup(context, images[index], titles[index]);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                child: Stack(
                                  children: [
                                    // Resim
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            const Color.fromARGB(178, 0, 0, 0),
                                          ],
                                          stops: const [0.6, 1.0],
                                        ),
                                      ),
                                    ),
                                    // resimin üstündeki yazı
                                    Positioned(
                                      left: 16,
                                      bottom: 12,
                                      child: Text(
                                        titles[index],
                                        style: const TextStyle(
                                          fontFamily: 'Ubuntu',
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isFavoriteNearby[index] =
                                                !isFavoriteNearby[index];
                                            if (isFavoriteNearby[index]) {
                                              _favoritesService.addToFavorites(
                                                  images[index], titles[index]);
                                            } else {
                                              _favoritesService
                                                  .removeFromFavorites(
                                                      titles[index]);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isFavoriteNearby[index]
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavoriteNearby[index]
                                              ? Colors.red
                                              : Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // bölgeler kısmı - always show but filter based on search
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 24),
                      child: Text(
                        isSearchActive ? 'Arama Sonuçları' : 'Bölgeler',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    SizedBox(),
                    Container(
                      width: deviceWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10),
                          // For search results, use a different layout
                          if (isSearchActive) 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                alignment: WrapAlignment.start,
                                children: [
                                  if ('Ege Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage('assets/images/bolgeler/ege.jpg',
                                        'Ege Bölgesi', deviceWidth * 0.44, context),
                                  if ('Karadeniz Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage(
                                        'assets/images/bolgeler/karadeniz.jpg',
                                        'Karadeniz Bölgesi',
                                        deviceWidth * 0.44,
                                        context),
                                  if ('Doğu Anadolu Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage(
                                        'assets/images/bolgeler/dogu_anadolu.jpg',
                                        'Doğu Anadolu Bölgesi',
                                        deviceWidth * 0.44,
                                        context),
                                  if ('İç Anadolu Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage(
                                        'assets/images/bolgeler/ic_anadolu.jpg',
                                        'İç Anadolu Bölgesi',
                                        deviceWidth * 0.44,
                                        context),
                                  if ('Güneydoğu Anadolu'.toLowerCase().contains(_searchQuery))
                                    _buildImage(
                                        'assets/images/bolgeler/guneydogu_anadolu.jpg',
                                        'Güneydoğu Anadolu',
                                        deviceWidth * 0.44,
                                        context),
                                  if ('Marmara Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage(
                                        'assets/images/bolgeler/marmara.jpg',
                                        'Marmara Bölgesi',
                                        deviceWidth * 0.44,
                                        context),
                                  if ('Akdeniz Bölgesi'.toLowerCase().contains(_searchQuery))
                                    _buildImage('assets/images/bolgeler/akdeniz.jpg',
                                        'Akdeniz Bölgesi', deviceWidth * 0.44, context),
                                ],
                              ),
                            )
                          else
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildImage('assets/images/bolgeler/ege.jpg',
                                        'Ege Bölgesi', deviceWidth * 0.44, context),
                                    SizedBox(width: 10),
                                    _buildImage(
                                        'assets/images/bolgeler/karadeniz.jpg',
                                        'Karadeniz Bölgesi',
                                        deviceWidth * 0.44, context),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildImage(
                                        'assets/images/bolgeler/dogu_anadolu.jpg',
                                        'Doğu Anadolu Bölgesi',
                                        deviceWidth * 0.44, context),
                                    SizedBox(width: 10),
                                    _buildImage(
                                        'assets/images/bolgeler/ic_anadolu.jpg',
                                        'İç Anadolu Bölgesi',
                                        deviceWidth * 0.44, context),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildImage(
                                        'assets/images/bolgeler/guneydogu_anadolu.jpg',
                                        'Güneydoğu Anadolu',
                                        deviceWidth * 0.44, context),
                                    SizedBox(width: 10),
                                    _buildImage(
                                        'assets/images/bolgeler/marmara.jpg',
                                        'Marmara Bölgesi',
                                        deviceWidth * 0.44, context),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: _buildImage('assets/images/bolgeler/akdeniz.jpg',
                                      'Akdeniz Bölgesi', deviceWidth * 0.88 + 10, context),
                                ),
                              ],
                            ),
                        ],
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
  }

  Widget _buildLocationContainer() {
    return Container(
      width: 205,
      height: 38,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 188, 184, 184),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 35, color: Colors.black),
          Text(
            "Türkiye",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Color.fromARGB(255, 188, 184, 184),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon:
              Icon(Icons.search, color: Color.fromARGB(255, 167, 167, 167)),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
      ),
    );
  }

  final Map<String, String> regionMap = {
    'Ege Bölgesi': 'Ege',
    'Karadeniz Bölgesi': 'Karadeniz',
    'Doğu Anadolu Bölgesi': 'Doğu Anadolu',
    'İç Anadolu Bölgesi': 'İç Anadolu',
    'Marmara Bölgesi': 'Marmara',
    'Güneydoğu Anadolu Bölgesi': 'Güneydoğu Anadolu',
    'Akdeniz Bölgesi': 'Akdeniz'
  };

  Widget _buildRegionRow(BuildContext context, String image1, String title1,
      String image2, String title2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImage(image1, title1, 182, context),
        SizedBox(width: 12),
        _buildImage(image2, title2, 182, context),
      ],
    );
  }

  Widget _buildRouteItem({
    required String title,
    required String imageUrl,
    required String duration,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontFamily: 'Ubuntu', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 5),
            Text(
              'Süre: $duration',
              style: TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
      String imagePath, String title, double width, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegionCitiesPage(regionName: regionMap[title] ?? title),
          ),
        );
      },
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Yazı için gradient overlay
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
            // Yazı
            Positioned(
              left: 10,
              bottom: 10,
              child: Text(
                title,
                style: const TextStyle(
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
}
