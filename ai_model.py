import os
import random
import requests
from datetime import timedelta
from geopy.distance import geodesic
import argparse

def kullanici_bilgileri_cek(konum_bilgisi=None):
    if konum_bilgisi:
        # Navigasyon sayfasından gelen konum bilgisini kullan
        konumBilgisi = konum_bilgisi
    else:
        # Varsayılan konum bilgisi
        konumBilgisi = {"enlem": 41.0104, "boylam": 28.9484}
    
    ilgiAlaniSiralamasi = ["Müze", "Tarihi Yer", "Doğa", "Yemek"]
    favoriMekanlarSayilari = {"Müze": 10, "Tarihi Yer": 5, "Doğa": 3, "Yemek": 2}
    #! yukarıdaki bilgiler FireBase'den çekilecek
    return konumBilgisi, ilgiAlaniSiralamasi, favoriMekanlarSayilari

def veri_seti_oku():

    mekanlar = []
    with open("assets/istanbul_mekanlari.csv", "r", encoding="utf-8") as file:
        reader = file.readlines()[1:]
        for satir in reader:
            enlem = float(satir.split(",")[0])
            boylam = float(satir.split(",")[1])
            kategori = satir.split(",")[2]
            bilinirlik = int(satir.split(",")[3])
            mekan_adi = satir.split(",")[4].strip()
            mekanlar.append({
                "enlem": enlem,
                "boylam": boylam,
                "kategori": kategori,
                "bilinirlik": bilinirlik,
                "mekan_adi": mekan_adi
            })
    return mekanlar

def ilgi_alani_puanlama(mekanKategorisi):

    ilgiAlaniSiralamasi = kullanici_bilgileri_cek()[1]
    sira = ilgiAlaniSiralamasi.index(mekanKategorisi)
    return 4 - sira

def mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekanEnlem, mekanBoylam):

    mesafe = geodesic((anlikKonumEnlem, anlikKonumBoylam), (mekanEnlem, mekanBoylam)).kilometers
    return mesafe

def en_iyi_mekan_bul(anlikKonumEnlem, anlikKonumBoylam, mekanlar):
    
    puanliMekanlar = []
    
    for mekan in mekanlar:
        sira = ilgi_alani_puanlama(mekan["kategori"])
        mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
        bilinirlik = mekan["bilinirlik"]
        puan = (4 * sira) - (0.1 * mesafe) + (0.3 * bilinirlik)
        puanliMekanlar.append({"puan": puan, "mekan": mekan})
    
    puanliMekanlar.sort(key=lambda x: x["puan"], reverse=True)
    secilenMekan = puanliMekanlar[0]["mekan"]
    
    return secilenMekan

def seyahat_suresi_hesapla(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam, ulasimModu=None):

    mesafe = mesafe_hesaplama(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam)
    
    if mesafe < 1:
        ulasimModu = "walking"
    else:

        if ulasimModu is None:
            yurumeSuresi, _ = seyahat_suresi_api_ile_hesapla(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam, "walking")
            topluTasimaSuresi, _ = seyahat_suresi_api_ile_hesapla(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam, "transit")
            
            if yurumeSuresi is None or topluTasimaSuresi is None:
                yaklasik_sure = mesafe * 12
                return yaklasik_sure, mesafe
            
            ulasimModu = "walking" if yurumeSuresi <= topluTasimaSuresi else "transit"
    
    sure, _ = seyahat_suresi_api_ile_hesapla(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam, ulasimModu)
    
    if sure is None:
        yaklasik_sure = mesafe * 12
        return yaklasik_sure, mesafe
    
    return sure, mesafe

def seyahat_suresi_api_ile_hesapla(baslangicEnlem, baslangicBoylam, bitisEnlem, bitisBoylam, ulasimModu):
    
    api_key = os.environ.get("GOOGLE_MAPS_API_KEY", "AIzaSyAOVYRIgupAurZup5y1PRh8Ismb1A3lLao")
    url = "https://maps.googleapis.com/maps/api/distancematrix/json"
    params = {
        "origins": f"{baslangicEnlem},{baslangicBoylam}",
        "destinations": f"{bitisEnlem},{bitisBoylam}",
        "mode": ulasimModu,
        "key": api_key
    }
    
    try:
        response = requests.get(url, params=params)
        data = response.json()

        if data["status"] == "OK" and data["rows"][0]["elements"][0]["status"] == "OK":
            sure = data["rows"][0]["elements"][0]["duration"]["value"] / 60
            mesafe = data["rows"][0]["elements"][0]["distance"]["value"] / 1000
            
            return sure, mesafe
        else:
            return None, None
    except:
        return None, None

def ziyaret_suresi_belirle(kategori):

    muzeSure = random.randint(30,60)
    tarihiYerSure = random.randint(30,45)
    doğaSure = random.randint(30,75)
    yemekSure = random.randint(30,45)

    ziyaret_sureleri = {
        "Müze": muzeSure,
        "Tarihi Yer": tarihiYerSure,
        "Doğa": doğaSure,
        "Yemek": yemekSure
    }
    
    return ziyaret_sureleri.get(kategori)

def ilk_rotayi_olustur(konum_bilgisi=None):
    rota = []
    mekanlar = veri_seti_oku()
    mekanlarTemp = mekanlar.copy()
    
    kullanici_bilgisi = kullanici_bilgileri_cek(konum_bilgisi)
    anlikKonumEnlem = kullanici_bilgisi[0]["enlem"]
    anlikKonumBoylam = kullanici_bilgisi[0]["boylam"]
    
    toplamSeyahatSuresi = 0
    toplamZiyaretSuresi = 0
    toplamMesafe = 0
    
    yemek_molasi_eklendi = False
    ikinci_ilgi_alani_aktif = False
    ilgi_alanlari = kullanici_bilgileri_cek()[1]
    ikinci_ilgi_alani = ilgi_alanlari[1] if len(ilgi_alanlari) > 1 else None
    
    for i in range(5):

        if toplamSeyahatSuresi + toplamZiyaretSuresi >= 180 and not yemek_molasi_eklendi:
            yemek_mekanlari = [mekan for mekan in mekanlarTemp if mekan["kategori"] == "Yemek"]
            
            if yemek_mekanlari:
                puanliYemekMekanlari = []
                for mekan in yemek_mekanlari:
                    mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
                    bilinirlik = mekan["bilinirlik"]
                    puan = (0.7 * bilinirlik) - (0.3 * mesafe)
                    puanliYemekMekanlari.append({"puan": puan, "mekan": mekan})
                
                puanliYemekMekanlari.sort(key=lambda x: x["puan"], reverse=True)
                secilenMekan = puanliYemekMekanlari[0]["mekan"]
                yemek_molasi_eklendi = True
                ikinci_ilgi_alani_aktif = True
                
            else:
                puanliMekanlar = []
                for mekan in mekanlarTemp:
                    sira = ilgi_alani_puanlama(mekan["kategori"])
                    mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
                    bilinirlik = mekan["bilinirlik"]
                    puan = (4 * sira) - (0.1 * mesafe) + (0.3 * bilinirlik)
                    puanliMekanlar.append({"puan": puan, "mekan": mekan})
                
                puanliMekanlar.sort(key=lambda x: x["puan"], reverse=True)
                secilenMekan = puanliMekanlar[0]["mekan"]
        else:
            puanliMekanlar = []

            for mekan in mekanlarTemp:
                if ikinci_ilgi_alani_aktif and ikinci_ilgi_alani:

                    kategori_bonus = 5 if mekan["kategori"] == ikinci_ilgi_alani else 0
                    sira = ilgi_alani_puanlama(mekan["kategori"])
                    mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
                    bilinirlik = mekan["bilinirlik"]
                    puan = (4 * sira) - (0.1 * mesafe) + (0.3 * bilinirlik) + kategori_bonus
                else:
                    sira = ilgi_alani_puanlama(mekan["kategori"])
                    mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
                    bilinirlik = mekan["bilinirlik"]
                    puan = (4 * sira) - (0.1 * mesafe) + (0.3 * bilinirlik)
                puanliMekanlar.append({"puan": puan, "mekan": mekan})
            
            puanliMekanlar.sort(key=lambda x: x["puan"], reverse=True)
            secilenMekan = puanliMekanlar[0]["mekan"]
        
        seyahat_suresi, mesafe = seyahat_suresi_hesapla(anlikKonumEnlem, anlikKonumBoylam, secilenMekan["enlem"], secilenMekan["boylam"])
        
        ulasimModu = "Yürüyüş" if mesafe < 1 else "Toplu Taşıma"
        if mesafe >= 1:
            yurumeSuresi, _ = seyahat_suresi_api_ile_hesapla(anlikKonumEnlem, anlikKonumBoylam,  secilenMekan["enlem"], secilenMekan["boylam"], "walking")
            topluTasimaSuresi, _ = seyahat_suresi_api_ile_hesapla(anlikKonumEnlem, anlikKonumBoylam,  secilenMekan["enlem"], secilenMekan["boylam"], "transit")
            
            if yurumeSuresi is not None and topluTasimaSuresi is not None:
                ulasimModu = "Yürüyüş" if yurumeSuresi <= topluTasimaSuresi else "Toplu Taşıma"
        
        ziyaret_suresi = ziyaret_suresi_belirle(secilenMekan["kategori"])
        
        toplamSeyahatSuresi += seyahat_suresi
        toplamZiyaretSuresi += ziyaret_suresi
        toplamMesafe += mesafe
        
        secilenMekan["seyahat_suresi"] = seyahat_suresi
        secilenMekan["seyahat_mesafesi"] = mesafe
        secilenMekan["ziyaret_suresi"] = ziyaret_suresi
        secilenMekan["ulasimModu"] = ulasimModu
        rota.append(secilenMekan)
        
        anlikKonumEnlem = secilenMekan["enlem"]
        anlikKonumBoylam = secilenMekan["boylam"]
        mekanlarTemp.remove(secilenMekan)
            
    return rota

def alternatif_rotayi_olustur(ilk_rota=None, konum_bilgisi=None):
    rota = []
    mekanlar = veri_seti_oku()

    if ilk_rota:
        ilk_rota_mekan_adlari = [mekan["mekan_adi"] for mekan in ilk_rota]
        mekanlarTemp = [mekan for mekan in mekanlar if mekan["mekan_adi"] not in ilk_rota_mekan_adlari]
    else:
        mekanlarTemp = mekanlar.copy()
    
    kullanici_bilgisi = kullanici_bilgileri_cek(konum_bilgisi)
    anlikKonumEnlem = kullanici_bilgisi[0]["enlem"]
    anlikKonumBoylam = kullanici_bilgisi[0]["boylam"]
    
    toplamSeyahatSuresi = 0
    toplamZiyaretSuresi = 0
    toplamMesafe = 0
    
    yemek_molasi_eklendi = False
    ilgi_alanlari = kullanici_bilgileri_cek()[1]
    kategori_sayaclari = {kategori: 0 for kategori in ilgi_alanlari}

    hedef_kategori_dagilimi = {}
    if len(ilgi_alanlari) >= 1:
        hedef_kategori_dagilimi[ilgi_alanlari[0]] = 2
    if len(ilgi_alanlari) >= 2:
        hedef_kategori_dagilimi[ilgi_alanlari[1]] = 1
    if len(ilgi_alanlari) >= 3:
        hedef_kategori_dagilimi[ilgi_alanlari[2]] = 1
    
    for i in range(5):
        if toplamSeyahatSuresi + toplamZiyaretSuresi >= 180 and not yemek_molasi_eklendi:
            yemek_mekanlari = [mekan for mekan in mekanlarTemp if mekan["kategori"] == "Yemek"]
            
            if yemek_mekanlari:
                puanliYemekMekanlari = []

                for mekan in yemek_mekanlari:
                    mesafe = mesafe_hesaplama(anlikKonumEnlem, anlikKonumBoylam, mekan["enlem"], mekan["boylam"])
                    bilinirlik = mekan["bilinirlik"]
                    puan = (0.7 * bilinirlik) - (0.3 * mesafe)
                    puanliYemekMekanlari.append({"puan": puan, "mekan": mekan})
                
                puanliYemekMekanlari.sort(key=lambda x: x["puan"], reverse=True)
                secilenMekan = puanliYemekMekanlari[0]["mekan"]
                yemek_molasi_eklendi = True

            else:
                secilenMekan = kategori_bazli_mekan_sec(mekanlarTemp, anlikKonumEnlem, anlikKonumBoylam, kategori_sayaclari, hedef_kategori_dagilimi)
        else:
            secilenMekan = kategori_bazli_mekan_sec(mekanlarTemp, anlikKonumEnlem, anlikKonumBoylam, kategori_sayaclari, hedef_kategori_dagilimi)
        

        if secilenMekan["kategori"] in kategori_sayaclari:
            kategori_sayaclari[secilenMekan["kategori"]] += 1
        
        seyahat_suresi, mesafe = seyahat_suresi_hesapla(anlikKonumEnlem, anlikKonumBoylam, secilenMekan["enlem"], secilenMekan["boylam"])
        ulasimModu = "Yürüyüş" if mesafe < 1 else "Toplu Taşıma"

        if mesafe >= 1:
            yurumeSuresi, _ = seyahat_suresi_api_ile_hesapla(anlikKonumEnlem, anlikKonumBoylam, secilenMekan["enlem"], secilenMekan["boylam"], "walking")
            topluTasimaSuresi, _ = seyahat_suresi_api_ile_hesapla(anlikKonumEnlem, anlikKonumBoylam, secilenMekan["enlem"], secilenMekan["boylam"], "transit")
            
            if yurumeSuresi is not None and topluTasimaSuresi is not None:
                ulasimModu = "Yürüyüş" if yurumeSuresi <= topluTasimaSuresi else "Toplu Taşıma"

        ziyaret_suresi = ziyaret_suresi_belirle(secilenMekan["kategori"])    
        toplamSeyahatSuresi += seyahat_suresi
        toplamZiyaretSuresi += ziyaret_suresi
        toplamMesafe += mesafe
        
        secilenMekan["seyahat_suresi"] = seyahat_suresi
        secilenMekan["seyahat_mesafesi"] = mesafe
        secilenMekan["ziyaret_suresi"] = ziyaret_suresi
        secilenMekan["ulasimModu"] = ulasimModu
        rota.append(secilenMekan)
        
        anlikKonumEnlem = secilenMekan["enlem"]
        anlikKonumBoylam = secilenMekan["boylam"]
        mekanlarTemp.remove(secilenMekan)

    return rota

def kategori_bazli_mekan_sec(mekanlar, konum_enlem, konum_boylam, kategori_sayaclari, hedef_kategori_dagilimi):

    eksik_kategoriler = [k for k, v in hedef_kategori_dagilimi.items() if kategori_sayaclari.get(k, 0) < v]    
    puanliMekanlar = []
    
    for mekan in mekanlar:

        kategori_bonus = 0
        if mekan["kategori"] in eksik_kategoriler:

            kategori_bonus = 10
            if mekan["kategori"] == eksik_kategoriler[0] if eksik_kategoriler else None:
                kategori_bonus += 5
        
        sira = ilgi_alani_puanlama(mekan["kategori"])
        mesafe = mesafe_hesaplama(konum_enlem, konum_boylam, mekan["enlem"], mekan["boylam"])
        bilinirlik = mekan["bilinirlik"]
        puan = (4 * sira) - (0.1 * mesafe) + (0.3 * bilinirlik) + kategori_bonus
        puanliMekanlar.append({"puan": puan, "mekan": mekan})
    
    puanliMekanlar.sort(key=lambda x: x["puan"], reverse=True)
    
    return puanliMekanlar[0]["mekan"] if puanliMekanlar else None

# Ana fonksiyon - dışarıdan çağrılabilir
def rota_olustur(konum_bilgisi=None):
    """
    Navigasyon sayfasından gelen konum bilgisine göre rotalar oluşturur
    ve bu rotaları döndürür.
    
    Args:
        konum_bilgisi (dict, optional): {"enlem": float, "boylam": float} formatında konum bilgisi
        
    Returns:
        dict: İlk ve alternatif rotaları içeren sözlük
    """
    ilk_rota = ilk_rotayi_olustur(konum_bilgisi)
    alternatif_rota = alternatif_rotayi_olustur(ilk_rota, konum_bilgisi)
    
    return {
        "ilk_rota": ilk_rota,
        "alternatif_rota": alternatif_rota
    }

# Komut satırı argümanlarını işle
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='AI TouriTech Rota Oluşturma')
    parser.add_argument('--enlem', type=float, help='Başlangıç konumu enlemi')
    parser.add_argument('--boylam', type=float, help='Başlangıç konumu boylamı')
    
    args = parser.parse_args()
    
    # Konum bilgisi varsa kullan
    konum_bilgisi = None
    if args.enlem is not None and args.boylam is not None:
        konum_bilgisi = {"enlem": args.enlem, "boylam": args.boylam}
        print(f"Alınan konum bilgisi: Enlem={args.enlem}, Boylam={args.boylam}")
    
    # Rotaları oluştur
    rotalar = rota_olustur(konum_bilgisi)
    
    # JSON formatında çıktı ver
    import json
    print(json.dumps(rotalar))