import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';//

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu', // Set Ubuntu as the default font family
      ),
      home: LoadBalanceScreen(),
    );
  }
}

class LoadBalanceScreen extends StatefulWidget {
  const LoadBalanceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadBalanceScreenState createState() => _LoadBalanceScreenState();
}

class _LoadBalanceScreenState extends State<LoadBalanceScreen> {
  int? selectedAmount;
  String selectedCard = "Banka/kredi kartı seç";

  void _showMasterpassModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFF9F7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kayıtlı ödeme araçlarım",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Ödeme yapmak istediğin kartını seç"),
              Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset("assets/masterpass_logo.jpg",
                        width: 70),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _cardInfos(
                    context,
                  ); // Bu satırda _cardInfos fonksiyonunu çağırıyoruz
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF9F7F7),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 208, 208, 208),
                    width: 1,
                  ),
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Row'nun sadece içeriği kadar genişlemesini sağlar
                  mainAxisAlignment:
                      MainAxisAlignment.center, // İçeriği ortalar
                  children: [
                    Image.asset(
                      'assets/add.jpg', // Görsel dosyasının yolu
                      width: 18, // Görselin boyutu
                      height: 18, // Görselin yüksekliği
                    ),
                    SizedBox(width: 8), // Görsel ile metin arasına boşluk ekler
                    Text(
                      "Yeni kart gir",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cardInfos(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran için bu özellik aktif olmalı
      backgroundColor: Color(0xFFF9F7F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Banka veya kredi kartı gir",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Ödeme yapmak istediğin kartını seç"),
              SizedBox(height: 20),

              // Kart numarası girişi
              TextField(
                decoration: InputDecoration(
                  labelText: "Kart Numarası",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Son kullanma tarihi girişi
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Son Kullanma Tarihi (MM/YY)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "CVV",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true, // CVV gizli olmalı
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Kart ismi girişi
              TextField(
                decoration: InputDecoration(
                  labelText: "Kartına İsim Ver",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Masterpass ile kaydetme seçeneği
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(value: false, onChanged: (bool? value) {}),
                  Flexible(
                    child: Text(
                      "Bu kartı daha sonra kullanmak için Masterpass sistemine kaydetmek ister misin?",
                      maxLines: 3, // Gerekirse alt satıra geçebilir
                      // Taşarsa üç nokta ile gösterir
                    ),
                  ),
                  SizedBox(width: 8), // Yazı ile logo arasında boşluk bırakır
                  Image.asset(
                    "assets/masterpass_logo.jpg",
                    height: 20, // Logonun uygun bir boyutta olması için
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Devam Et Butonu
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color.fromARGB(
                    255,
                    60,
                    62,
                    63,
                  ), // Arka plan rengi burada ayarlanır
                ),
                child: Text(
                  "Devam Et",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      Text(
        "Yükleme yapılacak kart",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dijital hesabım",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              "150,75 TL",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Text(
        "Ödeme aracı",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: () => _showMasterpassModal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Yazılar ve ok işareti arasında boşluk
          children: [
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Yazıları sola hizala
              children: [
                Text(
                  "Banka/kredi kartı seç",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 4), // Yazılar arası boşluk
                Text(
                  "Ödeme yapmak istediğin kartını seç",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(175, 0, 0, 0),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black,
            ), // Sağdaki ok işareti
          ],
        ),
      ),
      SizedBox(height: 20),
      Text(
        "Tutar",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [10, 20, 30, 50, 100, 150, 200, 500].map((amount) {
          return GestureDetector(
            onTap: () {
              setState(() {
                if (amount == 500) {
                  selectedAmount =
                      null; // "Diğer" seçildiğinde mevcut değeri sıfırla
                } else {
                  selectedAmount = amount;
                }
              });
            },
            child: Container(
              width: 80,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedAmount == amount ||
                        (amount == 500 && selectedAmount == null)
                    ? Colors.blue
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: amount == 500
                  ? (selectedAmount == null
                      ? TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onSubmitted: (value) {
                            setState(() {
                              selectedAmount = int.tryParse(value);
                            });
                          },
                        )
                      : Text(
                          "Diğer",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  : Text(
                      "$amount TL",
                      style: TextStyle(
                        color: selectedAmount == amount
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        }).toList(),
      ),
      Spacer(),
      Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Toplam tutar", style: TextStyle(fontSize: 16)),
            Text(
              selectedAmount != null ? "$selectedAmount TL" : "0,00 TL",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      SizedBox(height: 10),
      ElevatedButton(
        onPressed: selectedAmount != null ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(241, 45, 44, 66),
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Ödemeye geç",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      SizedBox(height: 20),
    ];
    return Scaffold(
      backgroundColor: Color(0xFFF9F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F7F7),
        title: Text("TL yükle"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}