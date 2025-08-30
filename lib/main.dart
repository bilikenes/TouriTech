import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/alt_bar.dart';
import 'widgets/yandan_acilir_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/login.dart'; // LoginPage'i içe aktar
import 'views/forgot_password.dart'; // Forgot password page dosyanız
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Tüm uygulama için durum çubuğu ikonlarını siyah yap
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Android için siyah ikonlar
    statusBarBrightness: Brightness.light, // iOS için siyah ikonlar
  ));
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android için siyah ikonlar
        statusBarBrightness: Brightness.light, // iOS için siyah ikonlar
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        home: LoginPage(), // LoginPage, uygulama başladığında gösterilecek sayfa
      ),
    );
  }
}