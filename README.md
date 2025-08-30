# 🌍 TouriTech

TouriTech, kullanıcıların seyahat deneyimlerini geliştirmek için tasarlanmış **çoklu platform destekli (iOS, Android, Web, Masaüstü)** bir mobil uygulamadır.  
Proje, Flutter ile geliştirilmiş kullanıcı dostu bir arayüz ve **Python tabanlı yapay zeka servisleri** ile güçlendirilmiştir.  

---

## ✨ Özellikler
- 🔹 **Çoklu Platform Desteği:** Android, iOS, Web ve masaüstü platformlarında çalışır.
- 🤖 **AI Destekli Backend:** Python tabanlı `ai_model.py` ve `api_server.py` ile akıllı öneriler.
- 📍 **Lokasyon Tabanlı İçerik:** Gezilecek yer önerileri, rota planlama (Gelecek özellikler).
- 🖼️ **Modern Flutter UI:** Materyal tasarım prensipleriyle şık ve kullanıcı dostu arayüz.
- 🔧 **Kolay Geliştirme:** Açık kaynaklı, modüler proje yapısı.

---

## 📂 Proje Yapısı

```text
TouriTech/
├── android/        # Android spesifik dosyalar
├── ios/            # iOS spesifik dosyalar
├── lib/            # Flutter uygulama kaynak kodları (Dart)
├── web/            # Web build dosyaları
├── windows/        # Windows build dosyaları
├── linux/          # Linux build dosyaları
├── macos/          # macOS build dosyaları
├── ai_model.py     # Yapay zeka modeli scripti
├── api_server.py   # Backend API sunucusu
├── pubspec.yaml    # Flutter bağımlılıkları
└── README.md       # Bu dosya
```


---

## 🚀 Kurulum ve Çalıştırma

### 1. Flutter Uygulamasını Çalıştırma
> Flutter SDK ve gerekli ortamın kurulu olduğundan emin olun: [Flutter Kurulum Rehberi](https://flutter.dev/docs/get-started/install)

```bash
# Repo'yu klonlayın
git clone https://github.com/bilikenes/TouriTech.git
cd TouriTech

# Flutter bağımlılıklarını yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
2. Backend API’yi Çalıştırma
Python 3.9+ ve gerekli kütüphaneler yüklü olmalı.

bash
Kodu kopyala
# Sanal ortam oluşturun (opsiyonel)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# API sunucusunu başlatın
python api_server.py
🛠️ Kullanılan Teknolojiler
Teknoloji	Açıklama
Flutter (Dart)	Mobil, web ve masaüstü arayüzleri
Python	AI modelleme ve API geliştirme
PyTorch/TensorFlow	AI modeli (Varsayılan)
REST API	Flutter uygulaması ve backend arası iletişim
SQLite/Firebase	Veri yönetimi (Seçenekli)

🔮 Yol Haritası
 Kullanıcı giriş/çıkış sistemi

 Gerçek zamanlı rota önerileri

 Harita entegrasyonu

 Otel ve restoran önerileri

 Favori yerler listesi

🤝 Katkıda Bulunma
Pull request'ler memnuniyetle karşılanır.
Büyük değişiklikler için önce bir issue açarak neyi değiştirmek istediğinizi tartışın.

Fork yapın (repo'yu kendi hesabınıza kopyalayın)

Yeni bir branch oluşturun (git checkout -b feature/yeni-ozellik)

Değişikliklerinizi commit edin (git commit -m "Feat: Yeni özellik eklendi")

Branch’inizi push edin (git push origin feature/yeni-ozellik)

Bir Pull Request açın

📜 Lisans
Bu proje MIT Lisansı altında yayınlanmıştır.
Daha fazla bilgi için LICENSE dosyasına göz atın.

👨‍💻 Geliştiriciler
Enes BİLİK on Github: @bilikenes
Buse ŞENGÜL on Github: @buseSengul
Gülsüm BASIK on Github: @Gulsumbsk
Merve AKGÜL on Github: @merveeakgul
Meryem Ezgi Ekin on Github: @CrissMoris


Proje: TouriTech

---

💡 Bu README şunları sağlıyor:  
- Modern ve okunaklı bir yapı (özellikler, kurulum, teknolojiler, katkı rehberi vb.)  
- Potansiyel geliştiricilere hızlı başlangıç imkânı  
- Projeyi profesyonel gösteren yol haritası ve lisans bilgisi