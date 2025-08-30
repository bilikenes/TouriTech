import 'package:flutter/material.dart';
import 'package:flutter_app_0/services/favorites_service.dart';
import 'package:flutter_app_0/widgets/yandan_acilir_menu.dart';

class Favoriler extends StatelessWidget {
  final FavoritesService _favoritesService = FavoritesService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Function(int)? onNavigate;

  Favoriler({
    super.key,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F7F7),
      drawer: CustomDrawer(onNavigate: onNavigate),
      appBar: AppBar(
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.bottomLeft,
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
                    'Favoriler',
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
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Favoriler yüklenirken hata oluştu.', 
                    style: TextStyle(fontFamily: 'Ubuntu')));
          }
          var favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'Henüz favori eklenmedi.',
                style: TextStyle(fontFamily: 'Ubuntu', fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Color.fromARGB(33, 46, 65, 101), width: 1.5)),
                color: const Color(0xFFDBE2EF),
                elevation: 0,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item['image'] ?? 'lib/assets/placeholder.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    item['title'] ?? 'Bilinmeyen',
                    style: TextStyle(fontFamily: 'Ubuntu'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _favoritesService.removeFromFavorites(item['title']);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
