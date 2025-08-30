import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:teknofestproje/Surekli_Kullan%C4%B1m/alt_bar.dart';
import 'dart:io';
import 'package:flutter_app_0/views/login.dart';
import 'widgets/yandan_acilir_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _profileImage;
  bool _isExpanded = false;

  String firstName = "Yükleniyor...";
  String email = "Yükleniyor...";
  String lastName = "Yükleniyor...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        var doc = await _firestore.collection("users").doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            firstName = doc.data()?["firstName"] ?? "Bilinmeyen Kullanıcı";
            lastName = doc.data()?["lastName"] ?? "Bilinmeyen Kullanıcı";
            email = doc.data()?["email"] ?? "Bilinmeyen E-posta";
          });
        } else {
          setState(() {
            firstName = "Ad bulunamadı";
            lastName = "Soyad bulunamadı";
            email = "E-posta bulunamadı";
          });
        }
      } else {
        setState(() {
          firstName = "Giriş yapılmadı";
          lastName = "Giriş yapılmadı";
          email = "Giriş yapılmadı";
        });
      }
    } catch (e) {
      print("Firestore hata: $e");
      setState(() {
        firstName = "Hata oluştu";
        email = "Hata oluştu";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showChangePasswordModal(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    ValueNotifier<bool> isObscure = ValueNotifier<bool>(true);
    ValueNotifier<bool> isObscureNew = ValueNotifier<bool>(true);
    ValueNotifier<bool> isObscureConfirm = ValueNotifier<bool>(true);
    String errorMessage = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Şeffaf arka plan
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Şifre Değiştir",
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 20, 
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                        "Mevcut Şifre", currentPasswordController, isObscure),
                    _buildPasswordField(
                        "Yeni Şifre", newPasswordController, isObscureNew),
                    _buildPasswordField("Yeni Şifre (Tekrar)",
                        confirmPasswordController, isObscureConfirm),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(fontFamily: 'Ubuntu', color: Colors.red),
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 63, 114, 175),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          setState(() {
                            errorMessage = "";
                          });

                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            setState(() {
                              errorMessage = "Yeni şifreler eşleşmiyor!";
                            });
                            return;
                          }

                          if (newPasswordController.text ==
                              currentPasswordController.text) {
                            setState(() {
                              errorMessage =
                                  "Yeni şifre mevcut şifre ile aynı olmamalı!";
                            });
                            return;
                          }

                          User? user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            setState(() {
                              errorMessage = "Giriş yapmadınız!";
                            });
                            return;
                          }

                          try {
                            // Kullanıcının e-posta ile tekrar kimlik doğrulaması
                            AuthCredential credential =
                                EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPasswordController.text,
                            );

                            await user.reauthenticateWithCredential(credential);

                            // Eğer kimlik doğrulama başarılıysa, şifreyi değiştir
                            await user
                                .updatePassword(newPasswordController.text);

                            // Kullanıcıya başarı mesajı göster
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Şifreniz başarıyla değiştirildi!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              errorMessage = "Şifre değiştirme başarısız:";
                            });
                          }
                        },
                        child: const Text(
                          "Şifreyi Güncelle",
                          style: TextStyle(fontFamily: 'Ubuntu', fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      ValueNotifier<bool> isObscure) {
    return ValueListenableBuilder(
      valueListenable: isObscure,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: controller,
            obscureText: value,
            style: TextStyle(fontFamily: 'Ubuntu'),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(fontFamily: 'Ubuntu'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  value ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  isObscure.value = !isObscure.value;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSSSItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8), // Elemanlar arasındaki boşluk
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color.fromARGB(
                  255, 63, 114, 175), // Başlığı vurgulamak için renk
            ),
          ),
          SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 14,
              color: const Color.fromARGB(221, 17, 45, 78),
              height: 1.4, // Satır aralığını biraz açarak okunabilirliği artır
            ),
          ),
        ],
      ),
    );
  }

  void _showSSSModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "SSS (Sıkça Sorulan Sorular)",
            style: TextStyle(fontFamily: 'Ubuntu', fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            // Kaydırma ekleyen widget
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSSSItem(
                    "1. Uygulama nasıl çalışıyor?",
                    "Uygulama, yapay zeka destekli algoritmalar ile kullanıcıların ilgi alanlarını ve tercihlerini analiz ederek "
                        "kişiselleştirilmiş gezi rotaları oluşturur. Kullanıcılara en uygun destinasyonlar, aktiviteler ve güzergahlar önerilir, "
                        "böylece seyahat planlaması kolay ve verimli hale gelir."),
                _buildSSSItem(
                    "2. Uygulama hangi ulaşım sistemleriyle entegre çalışıyor?",
                    "Uygulama, Türkiye genelinde geçerli olan QR kod tabanlı dijital ulaşım kartı ile tüm şehirlerde toplu taşıma araçlarını "
                        "kullanmanıza olanak tanır. Böylece her şehir için ayrı ulaşım kartı satın alma zorunluluğu ortadan kalkar."),
                _buildSSSItem(
                    "3. Gezi rotaları nasıl kişiselleştiriliyor?",
                    "Kullanıcılar seyahat tercihlerini belirttikten sonra yapay zeka, ilgi alanlarına en uygun mekanları ve aktiviteleri analiz "
                        "ederek bir gezi planı oluşturur. Ayrıca, anlık olarak hava durumu, trafik ve kullanıcı geri bildirimlerine göre rota güncellenebilir."),
                _buildSSSItem(
                    "4. Uygulama internet bağlantısı gerektiriyor mu?",
                    "Evet, öneri sistemleri ve dijital ulaşım kartı gibi özelliklerin çalışması için internet bağlantısı gereklidir. Ancak, oluşturulan "
                        "rotalar çevrimdışı olarak kaydedilebilir ve internet olmadan da görüntülenebilir."),
                _buildSSSItem(
                    "5. Uygulama hangi tür gezginler için uygundur?",
                    "Uygulama, bireysel gezginlerden ailelere, macera tutkunlarından kültürel keşif yapmak isteyenlere kadar her türden seyahat sever "
                        "için uygundur. Kullanıcı tercihleri doğrultusunda en ideal gezi planını sunar."),
              ],
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.close, size: 25, color: Colors.black87),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F7F7),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          // Üst Profil Bölümü
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 40),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 63, 114, 175),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Add the menu button and title at the top
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
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
                        'Profil',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Profile image and user info
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.grey)
                            : ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 219, 226, 239),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$firstName $lastName ",
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  " $email",
                  style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.white70,
                      fontSize: 18),
                ),
              ],
            ),
          ),

          // Menü Listesi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  ), // Reduced from 30 to 15 to decrease the space
              child: ListView(
                children: [
                  /* ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Bilgilerim'),
          onTap: () => _personalnfos(context),
        ),*/
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Şifremi Değiştir', style: TextStyle(fontFamily: 'Ubuntu')),
                    onTap: () => _showChangePasswordModal(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Sıkça Sorulan Sorular', style: TextStyle(fontFamily: 'Ubuntu')),
                    onTap: () => _showSSSModal(context),
                  ),

                  // Bize Ulaşın (Açılır/Kapanır Menü)
                  ListTile(
                    leading: const Icon(Icons.contact_mail),
                    title: const Text('Bize Ulaşın', style: TextStyle(fontFamily: 'Ubuntu')),
                    trailing: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),

                  if (_isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "İletişim için mail adresimize ulaşabilirsiniz:",
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: Color.fromARGB(117, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "codysseyteam@gmail.com",
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 16,
                              color: Color(0xFF3F72AF),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('Çeviri', style: TextStyle(fontFamily: 'Ubuntu')),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Güvenli Çıkış',
                      style: TextStyle(fontFamily: 'Ubuntu', color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginPage()), // LoginPage() 'login.dart' sayfanın widget'ı olmalı
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}