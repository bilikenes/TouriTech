import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';

//iş mantığını auth.dart

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Future<UserCredential?> loginWithGoogle() async {
  //   // Fonksiyon adı düzeltildi
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();
  //     final googleAuth = await googleUser?.authentication;

  //     final cred = GoogleAuthProvider.credential(
  //         idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
  //     return await _firebaseAuth.signInWithCredential(cred);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Kullanıcı giriş fonksiyonu
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
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
    // Firebase Authentication ile kullanıcı kaydını yap
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore'a ad ve soyadı kaydet
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
  }

  sendPasswordResetEmail(String email) {}
}