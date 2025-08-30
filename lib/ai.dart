import 'package:flutter/material.dart';
import 'package:flutter_app_0/ana_sayfa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoboKeşif',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Offset _buttonPosition = Offset(100, 100);
  void _showAIImagePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'lib/assets/image/giris/ai.png',
                width: 400,
                height: 600,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Popup'ı kapat
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 175,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTourRoutePopup(context);
                  },
                  child: Text(
                    'Rotalar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 138, 21, 21),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTourRoutePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Color.fromARGB(255, 0, 44, 119), width: 2),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Önerdiğimiz Gezi rotası:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 350,
              height: 500,
              child: Column(
                children: [
                  /* bunlar firebaseden çekilcekk */
                  _tourPlace(
                      "Sultan Ahmet", "assetss/sultanahmet.jpg", "2 saat"),
                  _tourPlace(
                      "Galata Kulesi", "assetss/galatakulesi.jpg", "1.5 saat"),
                  _tourPlace(
                      "Kız Kulesi", "assetss/kizkulesikapak.png", "1 saat"),
                  _tourPlace("Yerebatan Sarnıcı",
                      "assetss/yerebatansarnici.png", "30  dakika"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Alternatif rota oluşturma işlemi
                    _showAlternativeRoutePopup(context);
                  },
                  child: Text(
                    "Alternatif Rota",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Rotayı hazırla işlemi
                    _prepareRoute();
                  },
                  child: Text(
                    "Rotayı Hazırla",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _tourPlace(String placeName, String imagePath, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Color.fromARGB(255, 223, 219, 219), width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(255, 223, 219, 219),
                blurRadius: 5,
                spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  duration,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAlternativeRoutePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alternatif Rota Oluşturuluyor..."),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Alternatif gezi rotası üzerinde çalışılıyor."),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTourRoutePopup(context);
                  },
                  child: Text("Geri Dön"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _prepareRoute() {
    // Burada rotayı hazırlama işlemi yapayzeka modeli gelcekk
    print("Rotayı Hazırladınız!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RoboKeşif'),
      ),
      body: Stack(
        children: [
          Center(
            child: Text('Ana Sayfa İçeriği'),
          ),
          Positioned(
            left: _buttonPosition.dx,
            top: _buttonPosition.dy,
            child: Draggable(
              feedback: FloatingActionButton(
                onPressed: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'lib/assets/image/giris/sanalasistan.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  _showAIImagePopup();
                },
                child: FloatingActionButton(
                  onPressed: () {
                    _showAIImagePopup();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assetss/sanalasistan.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _buttonPosition = details.offset;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}