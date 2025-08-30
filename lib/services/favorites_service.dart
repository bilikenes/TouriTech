import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToFavorites(String image, String title) async {
    await _firestore.collection('favorites').doc(title).set({
      'image': image,
      'title': title,
    });
  }

  Future<void> removeFromFavorites(String title) async {
    await _firestore.collection('favorites').doc(title).delete();
  }

  Stream<List<Map<String, dynamic>>> getFavorites() {
    return _firestore.collection('favorites').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}