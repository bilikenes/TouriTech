import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  List<String> imageNames = ["doga", "muze", "tarihiyerler", "yemek"];
  Map<String, String> displayNames = {
    "doga": "Doğa",
    "muze": "Müze",
    "tarihiyerler": "Tarihi Yerler",
    "yemek": "Yemek",
  };

  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
  List<String> selectedImagesOrder = ["", "", "", ""];

  void updateImageOrder(String selectedImage) {
    setState(() {
      if (selectedImagesOrder.contains(selectedImage)) {
        int index = selectedImagesOrder.indexOf(selectedImage);
        selectedImagesOrder[index] = "";
      } else {
        int emptyIndex = selectedImagesOrder.indexOf("");
        if (emptyIndex != -1) {
          selectedImagesOrder[emptyIndex] = selectedImage;
        }
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kayıt Başarılı', style: TextStyle(fontFamily: 'Ubuntu')),
          content: Text('Başarıyla kayıt oldunuz!', style: TextStyle(fontFamily: 'Ubuntu')),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam', style: TextStyle(fontFamily: 'Ubuntu', color: Color(0xFF112D4E))),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata', style: TextStyle(fontFamily: 'Ubuntu')),
          content: Text(message, style: TextStyle(fontFamily: 'Ubuntu')),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam', style: TextStyle(fontFamily: 'Ubuntu')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _validateAndRegister() async {
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showErrorDialog("Lütfen tüm alanları doldurunuz.");
      return;
    }

    if (selectedImagesOrder.contains("")) {
      _showErrorDialog("Lütfen tüm görselleri sıralayınız.");
      return;
    }

    try {
      // Firebase Authentication ile kullanıcı kaydı yapıyoruz
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı başarıyla kaydedildiyse, Firestore'a da ekliyoruz
      User? user = userCredential.user;
      if (user != null) {
        // Firestore'a kullanıcı bilgilerini kaydediyoruz
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'preferences':
              selectedImagesOrder, // Kullanıcı tercihlerini kaydediyoruz
        });

        _showSuccessDialog(); // Başarı mesajını göster
      }
    } catch (e) {
      // Kayıt sırasında hata oluşursa kullanıcıya bildiriyoruz
      _showErrorDialog("Kayıt sırasında bir hata oluştu: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F7F7),
        title: Text("Kayıt Ol", style: TextStyle(fontFamily: 'Ubuntu')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  "Ad", (value) => setState(() => firstName = value)),
              _buildTextField(
                  "Soyad", (value) => setState(() => lastName = value)),
              _buildTextField(
                  "E-posta", (value) => setState(() => email = value)),
              _buildTextField(
                  "Şifre", (value) => setState(() => password = value),
                  obscureText: true),
              SizedBox(height: 20),
              Text("KİŞİSEL TERCİHLERİNİZE GÖRE SIRALAYINIZ",
                  style: TextStyle(fontFamily: 'Ubuntu', fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: imageNames.map((imageName) {
                  return GestureDetector(
                    onTap: () => updateImageOrder(imageName),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedImagesOrder.contains(imageName)
                                  ? HexColor("3F72AF")
                                  : Colors.transparent,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/$imageName.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              displayNames[imageName]!,
                              style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        if (selectedImagesOrder.contains(imageName))
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${selectedImagesOrder.indexOf(imageName) + 1}",
                                style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    color: Colors.white, 
                                    fontSize: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _validateAndRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("F9F7F7"),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                child: Text("Kayıt Ol"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, Function(String) onChanged,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Ubuntu',
            color: Colors.grey.shade600,
            fontSize: 16
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3366CC), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3366CC), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Color(0xFFF1F5FB),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }
}
