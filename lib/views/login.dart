import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için bu import'u ekleyin
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_app_0/widgets/alt_bar.dart';
import 'package:flutter_app_0/ana_sayfa.dart';
import 'package:flutter_app_0/controller/auth_controller.dart';
import 'package:flutter_app_0/controller/auth.dart';
import 'forgot_password.dart'; // ForgotPasswordPage'i içe aktar
import 'register.dart'; // Kayıt sayfasını içe aktar

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Durum çubuğu ikonlarını siyah yap
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android için siyah ikonlar
      statusBarBrightness: Brightness.light, // iOS için siyah ikonlar
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  // Sosyal medya butonlarına tıklanma işlemi
  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google ile giriş yapılıyor...")),
    );
  }

  void _loginWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Facebook ile giriş yapılıyor...")),
    );
  }

  void _loginWithApple() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Apple ile giriş yapılıyor...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar'ı tamamen şeffaf yap
        elevation: 0, // Gölgeyi kaldır: 0, // Gölgeyi kaldır
        title: Padding(
          padding: const EdgeInsets.only(
              top: 20.0), // Bu değeri isteğinize göre ayarlayın
          child: Center(
            child: Image.asset(
              'assets/logo.png', // Logonuzun yolu
              height: 100,
              width: 1100, // Logo boyutunu büyüttük
            ),
          ),
        ),
        toolbarHeight: 120,
        // AppBar'ın yüksekliğini artırıyoruz // AppBar'ın altındaki gölgeyi kaldırmak için
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/abcd.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 22),

                    // Login here text

                    const SizedBox(height: 12),
                    const Text(
                      'Dünyayı keşfetmeye başla,',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        color: Color(0xFF3366CC),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'en iyi rotalar seni bekliyor!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        color: Color(0xFF3366CC),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email zorunlu";
                        }
                        return null;
                      },
                      style: TextStyle(fontFamily: 'Ubuntu'),
                      decoration: InputDecoration(
                        hintText: 'E-Posta',
                        hintStyle: TextStyle(fontFamily: 'Ubuntu'),
                        filled: true,
                        fillColor: const Color(0xFFF1F5FB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3366CC),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3366CC),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3366CC),
                              width: 2), // Error border
                        ),
                        errorStyle: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black, // Hata mesajı rengini siyah yap
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre zorunlu';
                        }
                        return null;
                      },
                      style: TextStyle(fontFamily: 'Ubuntu'),
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        hintStyle: TextStyle(fontFamily: 'Ubuntu'),
                        filled: true,
                        fillColor: const Color(0xFFF1F5FB),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3366CC),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF3366CC),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF3366CC),
                              width: 2), // Error border
                        ),
                        errorStyle: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: Colors.black, // Hata mesajı rengini siyah yap
                        ),
                      ),
                      obscureText: true,
                    ),

// Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                          // Forgot password logic
                        },
                        child: const Text(
                          'Şifremi Unuttum',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Color(0xFF3366CC),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Sign in button
                    Consumer(
                      builder: (context, ref, child) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(authRepositoryProvider)
                                  .signInWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  )
                                  .then((value) {
                                // Eğer giriş başarılıysa
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MainScreen(), // Alt barın olduğu ana ekran
                                  ),
                                  (route) =>
                                      false, // Önceki sayfaları temizler (geri dönülemez)
                                );
                              }).catchError((error) {
                                // Giriş başarısızsa hata mesajını göster
                                if (error.code == 'user-not-found') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Böyle bir hesap bulunamadı", style: TextStyle(fontFamily: 'Ubuntu'))),
                                  );
                                } else if (error.code == 'wrong-password') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Yanlış şifre", style: TextStyle(fontFamily: 'Ubuntu'))),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Bir hata oluştu: ${error.message}", style: TextStyle(fontFamily: 'Ubuntu'))),
                                  );
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9F7F7), // Butonun arkaplan rengini 0xFFF9F7F7 olarak ayarladım
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20), // Burada oval yapabilirsiniz
                            ),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            minimumSize: Size(150, 50), // Buton boyutu
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Giriş Yap",
                              style: TextStyle(fontFamily: 'Ubuntu', color: Colors.black),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    // Create new account

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Hesabınız yok mu? Yeni Hesap Aç",
                        style: TextStyle(fontFamily: 'Ubuntu', color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Or continue with
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'veya',
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: Color(0xFF3366CC),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 26),
                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google
                        _socialLoginButton(
                          onTap: () {
                            _loginWithGoogle(); // Google ile giriş fonksiyonunu çağır
                          },
                          icon: 'G',
                        ),
                        const SizedBox(width: 16),
                        // Facebook
                        _socialLoginButton(
                          onTap: () {
                            _loginWithFacebook();
                            // Facebook login logic
                          },
                          icon: 'f',
                        ),
                        const SizedBox(width: 16),
                        // Apple
                        _socialLoginButton(
                          onTap: () {
                            _loginWithApple();
                            // Apple login logic
                          },
                          icon: '',
                          isApple: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required VoidCallback onTap,
    required String icon,
    bool isApple = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isApple
              ? const Icon(
                  Icons.apple,
                  size: 28,
                )
              : Text(
                  icon,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}