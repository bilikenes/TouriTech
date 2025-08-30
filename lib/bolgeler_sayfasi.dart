import 'package:flutter/material.dart';
import 'package:flutter_app_0/widgets/region_cities_page.dart'; // Yeni eklenen sayfayı dahil ediyoruz
import 'package:flutter_app_0/widgets/yandan_acilir_menu.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> regionMap = {
    'Ege Bölgesi': 'Ege',
    'Karadeniz Bölgesi': 'Karadeniz',
    'Doğu Anadolu Bölgesi': 'Doğu Anadolu',
    'İç Anadolu Bölgesi': 'İç Anadolu',
    'Marmara Bölgesi': 'Marmara',
    'Güneydoğu Anadolu Bölgesi': 'Güneydoğu Anadolu',
    'Akdeniz Bölgesi': 'Akdeniz'
  };

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _filterRegions(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F7), // Sayfanın arka plan rengi
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F7), // AppBar'ın arka plan rengi
        elevation: 0, // Gölge yok
        toolbarHeight: 0, // AppBar yüksekliği sıfır
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: const Color(0xFFF9F7F7), // Status bar rengi
          statusBarIconBrightness: Brightness.dark, // Status bar ikonları koyu renk
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            SizedBox(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: _buildLocationContainer(),
                  ),
                ),
                SizedBox(width: 48), // IconButton genişliğine eşit boşluk
              ],
            ),
            SizedBox(height: 15),
            _buildSearchField(),
            SizedBox(height: 20),
            Column(
              children: [
                SizedBox(height: 10), // Bölge resimleri arasındaki dikey boşluğu artırır
                
                // Arama sonuçları için merkezi bir düzen
                if (_searchQuery.isNotEmpty) 
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if ('Ege Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage('assets/images/bolgeler/ege.jpg', 'Ege Bölgesi',
                              deviceWidth * 0.44, context),
                        if ('Karadeniz Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage('assets/images/bolgeler/karadeniz.jpg',
                              'Karadeniz Bölgesi', deviceWidth * 0.44, context),
                        if ('Doğu Anadolu Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage('assets/images/bolgeler/dogu_anadolu.jpg',
                              'Doğu Anadolu Bölgesi', deviceWidth * 0.44, context),
                        if ('İç Anadolu Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage('assets/images/bolgeler/ic_anadolu.jpg',
                              'İç Anadolu Bölgesi', deviceWidth * 0.44, context),
                        if ('Marmara Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage('assets/images/bolgeler/marmara.jpg',
                              'Marmara Bölgesi', deviceWidth * 0.44, context),
                        if ('Güneydoğu Anadolu Bölgesi'.toLowerCase().contains(_searchQuery))
                          _buildImage(
                              'assets/images/bolgeler/guneydogu_anadolu.jpg',
                              'Güneydoğu Anadolu Bölgesi',
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImage('assets/images/bolgeler/ege.jpg', 'Ege Bölgesi',
                              deviceWidth * 0.44, context),
                          SizedBox(),
                          _buildImage('assets/images/bolgeler/karadeniz.jpg',
                              'Karadeniz Bölgesi', deviceWidth * 0.44, context),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImage('assets/images/bolgeler/dogu_anadolu.jpg',
                              'Doğu Anadolu Bölgesi', deviceWidth * 0.44, context),
                          SizedBox(),
                          _buildImage('assets/images/bolgeler/ic_anadolu.jpg',
                              'İç Anadolu Bölgesi', deviceWidth * 0.44, context),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImage('assets/images/bolgeler/marmara.jpg',
                              'Marmara Bölgesi', deviceWidth * 0.44, context),
                          SizedBox(),
                          _buildImage(
                              'assets/images/bolgeler/guneydogu_anadolu.jpg',
                              'Güneydoğu Anadolu',
                              deviceWidth * 0.44,
                              context),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (_searchQuery.isEmpty ||
                          'Akdeniz Bölgesi'.toLowerCase().contains(_searchQuery))
                        _buildImage('assets/images/bolgeler/akdeniz.jpg',
                            'Akdeniz Bölgesi', deviceWidth * 0.88 + 10, context),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationContainer() {
    return Container(
      width: 205,
      height: 40,
      decoration: BoxDecoration(
        color: (const Color(0xFFDBE2EF)!),
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
              fontFamily: "Ubuntu",
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterRegions,
              decoration: InputDecoration(
                hintText: 'Arama yapın...',
                hintStyle: TextStyle(
                  fontFamily: "Ubuntu",
                  color: Color(0xFF112D4E)),
                // Arama yapın... yazısının rengi
                prefixIcon: const Icon(Icons.search, color: Color(0xFF112D4E)),
                // büyüteç ikonu rengi
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF112D4E)),
                  // x ikonunun rengi
                  onPressed: () {
                    _searchController.clear();
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                // Sol ve sağ boşluk eklendi
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        margin: EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
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
                  fontFamily: "Ubuntu",
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
