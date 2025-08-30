class City {
  final String name;
  final String image;
  final String description; // Şehir açıklaması

  City({required this.name, required this.image, required this.description});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? "Bilinmeyen Şehir",
      image: json['image'] ?? "assets/images/sehirler/default_city.png", // Varsayılan resim
      description: json['description'] ?? "Açıklama yok", // Varsayılan açıklama
    );
  }
}