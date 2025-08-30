import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetLink() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      Utils.showSnackBar(context, "Lütfen geçerli bir e-posta girin.");
      return;
    }

    // Yükleniyor göstergesini aç
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop(); // Yüklenme göstergesini kapat
      Utils.showSnackBar(
          context, "Mailinize şifre sıfırlama bağlantısı gönderildi.");

      // Şifre sıfırlama sonrası login sayfasına yönlendirme
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      Utils.showSnackBar(context, e.message ?? "Bir hata oluştu");
    } catch (e) {
      Navigator.of(context).pop();
      Utils.showSnackBar(context, "Beklenmedik bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Şifremi Unuttum", style: TextStyle(fontFamily: 'Ubuntu')),
        backgroundColor: Color(0xFFF9F7F7),
      ),
      backgroundColor: Color(0xFFF9F7F7),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              style: TextStyle(fontFamily: 'Ubuntu'),
              decoration: InputDecoration(
                hintText: "E-Posta",
                hintStyle: TextStyle(fontFamily: 'Ubuntu'),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPasswordResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF9F7F7),
                foregroundColor: Colors.black,
              ),
              child: Text("Yeni Şifre Gönder", style: TextStyle(fontFamily: 'Ubuntu')),
            ),
          ],
        ),
      ),
    );
  }
}

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message, style: TextStyle(fontFamily: 'Ubuntu'))));
  }
}