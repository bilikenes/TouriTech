import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_0/controller/auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import edilmeli

//uygulama kontrolünü auth_controller.dart

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

class AuthController {
  final AuthRepository authRepository;

  AuthController({
    required this.authRepository,
  });

  // Kullanıcı giriş fonksiyonu
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Kullanıcı kayıt fonksiyonu
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return authRepository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  // Google ile giriş fonksiyonu
  // Future<UserCredential?> loginWithGoogle() async {
  //   return await authRepository.loginWithGoogle();
  // }

  // Şifre sıfırlama fonksiyonu
  Future<void> sendPasswordResetEmail({required String email}) async {
    return await authRepository.sendPasswordResetEmail(email);
  }
}