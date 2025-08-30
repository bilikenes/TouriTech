import 'package:flutter/material.dart';
import 'package:flutter_app_0/ana_sayfa.dart';
import 'package:flutter_app_0/profil_sayfasi.dart';
import 'package:flutter_app_0/favoriler_sayfasi.dart';
import 'package:flutter_app_0/bolgeler_sayfasi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int)? onNavigate;

  const CustomDrawer({Key? key, this.onNavigate}) : super(key: key);

  // Firestore'dan kullanıcı bilgilerini çekme fonksiyonu
  Future<Map<String, dynamic>?> getUserInfo() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9F7F7), // Arka plan rengi
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF112D4E), // Profil bilgileri arka plan rengi
            ),
            height: 200, // Profil kısmının yüksekliği
            child: Center(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: getUserInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Yüklenme animasyonu
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Text(
                      'Kullanıcı Bilgisi Bulunamadı',
                      style: TextStyle(fontFamily: 'Ubuntu', color: Colors.white),
                    );
                  }

                  String fullName =
                      "${snapshot.data!['firstName']} ${snapshot.data!['lastName']}";

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName, // Firestore'dan çekilen ad soyad
                        style: const TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerButton(
                    icon: Icons.location_city, text: "Şehirler", onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }),
                _buildDrawerButton(
                    icon: Icons.favorite,
                    text: "Favoriler",
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigate != null) {
                        onNavigate!(3);
                      }
                    }),
                _buildDrawerButton(
                    icon: Icons.person,
                    text: "Profil",
                    onTap: () {
                      Navigator.pop(context);
                      if (onNavigate != null) {
                        onNavigate!(4);
                      }
                    }),
                _buildDrawerButton(
                    icon: Icons.settings, text: "Ayarlar", onTap: () {}),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: _buildDrawerButton(
              icon: Icons.exit_to_app,
              text: "Çıkış Yap",
              iconColor: Colors.red,
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      Color iconColor = Colors.black}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 18)),
        ],
      ),
    );
  }
}