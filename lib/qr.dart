import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'TlYukle.dart';
import 'package:flutter_app_0/widgets/yandan_acilir_menu.dart';

class QRPage extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const QRPage({Key? key, this.onNavigate}) : super(key: key);
  
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  bool isScanning = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  double balance = 150.75;
  bool isPaid = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _checkCameraPermission();
  }

  void _fetchBalance() {
    setState(() {
      balance = 150.75; // Örnek bakiye
    });
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran genişliği ve yüksekliğini buradan alıyoruz
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F7F7),
      drawer: CustomDrawer(onNavigate: widget.onNavigate),
      body: SafeArea(
        child: Column(
          children: [
            // Arama çubuğu benzeri üst kısım
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      'QR Kod İşlemleri',
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
            
            SizedBox(height: 20),
            Text(
              isScanning ? 'QR Kodunu Okut' : 'Ulaşım için QR Göster ve Öde',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child:
                    isScanning ? buildQRScanner() : buildQRGenerator(screenWidth),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: buildToggleButton(),
            ),
            SizedBox(height: 10),
            buildDropdownMenu(),
          ],
        ),
      ),
    );
  }

  Widget buildQRGenerator(double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Color.fromARGB(255, 9, 64, 109), width: 6),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(15),
            child: QrImageView(
              data: "https://ornek-link.com", // QR kod linki
              size: screenWidth * 0.6, // Ekran genişliğine göre boyutlandırma
            ),
          ),
        ),
        SizedBox(height: 15),
        Text(
          "${balance.toStringAsFixed(2)} TL",
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
        Text(
          "Mevcut Bakiyeniz",
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 12, 
            fontWeight: FontWeight.w400, 
            color: Colors.grey
          ),
        ),
      SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Bakiye Yükle butonuna tıklandığında TlYükle sayfasına yönlendirme
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoadBalanceScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 9, 64, 109),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            "Bakiye Yükle",
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 16, 
              color: Colors.white
            )
          ),
        ),
      ],
    );
  }

  Widget buildQRScanner() {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: (QRViewController controller) {
            this.controller = controller;
            controller.scannedDataStream.listen((scanData) async {
              if (!isPaid) {
                setState(() {
                  isPaid = true;
                });

                // ✅ QR okutulduğunda "bip" sesi çal
                await player.play(AssetSource('sounds/beep.mp3'));

                // ✅ 2 saniye sonra ekranda mesajı temizle
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    isPaid = false;
                  });
                });
              }
            });
          },
        ),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromARGB(255, 9, 64, 109),
                width: 4,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => isScanning = !isScanning),
      child: Container(
        width: 220,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 300),
              alignment:
                  isScanning ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 110,
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 9, 64, 109),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "QR Göster",
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isScanning ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "QR Okut",
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isScanning ? Colors.white : Colors.black,
                      ),
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

  Widget buildDropdownMenu() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Diğer QR İşlemleri",
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 30),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "FAST TR Karekod oluştur",
                      style: TextStyle(fontFamily: 'Ubuntu')
                    ),
                    onTap: () {},
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "FAST TR Karekod ile para gönder",
                      style: TextStyle(fontFamily: 'Ubuntu')
                    ),
                    onTap: () {},
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "TR Karekod ile iade",
                      style: TextStyle(fontFamily: 'Ubuntu')
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 220,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Color.fromARGB(255, 9, 64, 109), width: 2),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          "Diğer QR İşlemleri",
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 9, 64, 109)
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
