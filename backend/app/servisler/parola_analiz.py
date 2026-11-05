"""PAROLA GÜCÜ ANALİZİ — iş kuralları (Hafta 6).

Analiz tamamen bu sunucuda, bellekte yapılır; hiçbir harici servise gönderilmez
(yerel analiz). Parola hiçbir yere yazılmaz: bu modül yalnızca ÖLÇÜMLER döndürür,
veritabanına da yalnızca bu ölçümler kaydedilir.

SKOR (0-100) = Uzunluk (en çok 40) + Çeşitlilik (en çok 40) + Benzersizlik (en çok 20) − Cezalar

  Uzunluk      : karakter başına 2,5 puan → 16 karakter ve üstü tam puan (40)
  Çeşitlilik   : küçük harf, büyük harf, rakam, özel karakter → her sınıf 10 puan
  Benzersizlik : farklı karakter sayısı / uzunluk × 20  ("aaaaaa" gibi parolaları cezalandırır)

  Cezalar (desenler):
    yaygın parola listesinde birebir       → skor en fazla 5
    yaygın parola + yalnızca rakam/sembol   → skor en fazla 15  (ör. Galatasaray1905)
    yaygın bir kelime içeriyor (≥4 harf)    → −30
    kişisel bilgi (ad, e-posta) içeriyor    → −30
    klavye deseni (qwer, asdf …)            → −15
    yalnızca rakamlardan oluşuyor           → −15
    ardışık dizi (abc, 123, cba …)          → −10
    aynı karakter 3+ kez art arda (aaa)     → −10
    yıl deseni (1900-2039)                  → −10

  Uzun parola cümlesi: 20+ karakterde çeşitlilik puanı en az 30 sayılır.

  İş kuralları (üst sınırlar):
    5'ten az farklı karakter en fazla 30 puan alır
    8 karakterden kısa parola en fazla 30 puan alır (her zaman "zayıf")
    12 karakterden kısa parola en fazla 69 puan alır ("güçlü" olamaz)

SEVİYE: 0-39 zayıf · 40-69 orta · 70-100 güçlü
"""
import math
import re

EN_KISA = 1
EN_UZUN = 128
SEVIYELER = (("zayif", 0), ("orta", 40), ("guclu", 70))

# En sık kullanılan parolalar (küçük harf, Türkçe karakterler sadeleştirilmiş).
# Kaynak: kamuya açık sızıntı istatistiklerinde ilk sıralarda yer alan parolalar + Türkiye'ye özgü olanlar.
YAYGIN_PAROLALAR = frozenset("""
123456 123456789 12345678 12345 1234567 1234567890 1234 111111 000000 123123 654321 666666
121212 112233 123321 987654321 555555 777777 888888 999999 11111111 147258369 159753 123654
password password1 password123 passw0rd admin admin123 root letmein welcome welcome1 login
qwerty qwerty123 qwertyuiop asdfgh asdfghjkl zxcvbnm 1q2w3e4r 1q2w3e qazwsx abc123 abcd1234
iloveyou monkey dragon football baseball sunshine princess master shadow superman batman
trustno1 starwars whatever freedom hello hello123 test test123 guest default secret
sifre sifre123 parola parola123 sifrem 123qwe qweasd asdasd qweqwe
galatasaray fenerbahce besiktas trabzonspor cimbom aslan kartal kanarya
turkiye istanbul ankara izmir askim seviyorum allah bismillah mehmet ahmet ayse fatma
""".split())

# Parolanın içinde aranacak yaygın kelimeler (en az 4 harf).
YAYGIN_KELIMELER = frozenset(k for k in YAYGIN_PAROLALAR if k.isalpha() and len(k) >= 4)

KLAVYE_SIRALARI = ("qwertyuiopgu", "asdfghjklsi", "zxcvbnmoc", "1qaz2wsx3edc")

_TR_SADE = str.maketrans("çğıöşüâîû", "cgiosuaiu")
_LEET = str.maketrans("@4310$5!7", "aaeiosslt")


class AnalizHatasi(Exception):
    def __init__(self, mesaj):
        super().__init__(mesaj)
        self.mesaj = mesaj


# ----------------------------------------------------------------- yardımcılar

def _tr_kucuk(metin):
    """Türkçe uyumlu küçük harf + Türkçe karakterleri sadeleştirme (Ş→s, İ→i …)."""
    return metin.replace("I", "ı").replace("İ", "i").lower().translate(_TR_SADE)


def _sadelestir(metin):
    """Karşılaştırma için: küçük harf, Türkçe sade, leet dönüşümü (P@ssw0rd → password)."""
    return _tr_kucuk(metin).translate(_LEET)


def karakter_siniflari(parola):
    return {
        "kucuk_harf": any(c.islower() for c in parola),
        "buyuk_harf": any(c.isupper() for c in parola),
        "rakam": any(c in "0123456789" for c in parola),
        "ozel_karakter": any(not c.isalnum() for c in parola),
    }


def entropi_hesapla(uzunluk, siniflar):
    """Kaba kuvvet entropisi (bit) = uzunluk × log2(karakter havuzu).
    Desenleri hesaba katmaz; bu yüzden ayrıca ceza puanları uygulanır."""
    havuz = (26 * siniflar.get("kucuk_harf", False) + 26 * siniflar.get("buyuk_harf", False)
             + 10 * siniflar.get("rakam", False) + 33 * siniflar.get("ozel_karakter", False))
    return round(uzunluk * math.log2(havuz)) if havuz and uzunluk else 0


def seviye_belirle(skor):
    seviye = SEVIYELER[0][0]
    for ad, alt_sinir in SEVIYELER:
        if skor >= alt_sinir:
            seviye = ad
    return seviye


def kirilma_suresi(entropi_bit, yaygin):
    """Saniyede 10 milyar tahmin yapabilen bir saldırgan için ortalama süre (kaba tahmin)."""
    if yaygin:
        return "anında"
    saniye = 2 ** max(entropi_bit - 1, 0) / 1e10
    for sinir, birim in ((60, "saniye"), (3600, "dakika"), (86400, "saat"),
                         (86400 * 365, "gün"), (86400 * 365 * 1000, "yıl")):
        if saniye < sinir:
            bolen = {"saniye": 1, "dakika": 60, "saat": 3600, "gün": 86400, "yıl": 86400 * 365}[birim]
            deger = saniye / bolen
            return "1 saniyeden az" if birim == "saniye" and deger < 1 else f"yaklaşık {deger:.0f} {birim}"
    return "binlerce yıldan fazla"


# ----------------------------------------------------------------- desenler

def _ardisik_var(metin):
    for i in range(len(metin) - 2):
        a, b, c = metin[i:i + 3]
        ayni_tur = (a + b + c).isdigit() or (a + b + c).isalpha()
        if ayni_tur and ord(b) - ord(a) == ord(c) - ord(b) and abs(ord(b) - ord(a)) == 1:
            return True
    return False


def _klavye_deseni_var(metin):
    for sira in KLAVYE_SIRALARI:
        for yon in (sira, sira[::-1]):
            if any(yon[i:i + 4] in metin for i in range(len(yon) - 3)):
                return True
    return False


def _kisisel_parcalar(ad_soyad, eposta):
    parcalar = set()
    for kelime in (ad_soyad or "").split():
        parcalar.add(_tr_kucuk(kelime))
    yerel = (eposta or "").split("@")[0]
    parcalar.update(_tr_kucuk(p) for p in re.split(r"[._\-+\d]+", yerel))
    return {p for p in parcalar if len(p) >= 3}


# ----------------------------------------------------------------- ana fonksiyon

def dogrula(parola):
    """Girdi doğrulama: yalnızca metin, 1-128 karakter."""
    if not isinstance(parola, str):
        raise AnalizHatasi("Parola metin olarak gönderilmelidir.")
    if len(parola) < EN_KISA:
        raise AnalizHatasi("Analiz için bir parola girin.")
    if len(parola) > EN_UZUN:
        raise AnalizHatasi(f"Parola en fazla {EN_UZUN} karakter olabilir.")


def analiz_et(parola, ad_soyad=None, eposta=None):
    """Parolayı analiz eder ve yalnızca ölçümleri döndürür (parolanın kendisi sonuçta yer almaz)."""
    dogrula(parola)

    uzunluk = len(parola)
    siniflar = karakter_siniflari(parola)
    farkli = len(set(parola))
    kucuk = _tr_kucuk(parola)                        # "Şifre123" → "sifre123"
    sade = _sadelestir(parola)                       # "P@ssw0rd" → "password"
    harf_kisimlari = {re.sub(r"[^a-z]", "", kucuk), re.sub(r"[^a-z]", "", sade)}  # rakam/sembol atılmış

    # --- temel ölçütler
    cesitlilik = 10 * sum(siniflar.values())
    cesitlilik_notu = f"{sum(siniflar.values())}/4 karakter türü"
    if uzunluk >= 20 and cesitlilik < 30:
        # Uzun parola cümlelerinde uzunluk, karakter çeşitliliğinden daha belirleyicidir.
        cesitlilik, cesitlilik_notu = 30, cesitlilik_notu + " (20+ karakter: uzunluk telafi eder)"
    olcutler = [
        {"ad": "Uzunluk", "puan": round(min(40, uzunluk * 2.5)), "en_fazla": 40,
         "aciklama": f"{uzunluk} karakter"},
        {"ad": "Çeşitlilik", "puan": cesitlilik, "en_fazla": 40, "aciklama": cesitlilik_notu},
        {"ad": "Benzersizlik", "puan": round(farkli / uzunluk * 20), "en_fazla": 20,
         "aciklama": f"{farkli} farklı karakter"},
    ]
    skor = sum(o["puan"] for o in olcutler)

    # --- desen cezaları
    bulgular = set()
    cezalar = []

    def ceza(kod, neden, puan):
        bulgular.add(kod)
        cezalar.append({"neden": neden, "puan": -puan})

    birebir_yaygin = kucuk in YAYGIN_PAROLALAR or sade in YAYGIN_PAROLALAR
    # "Galatasaray1905", "qwerty2024!": yaygın parolaya yalnızca rakam/sembol eklenmiş
    yaygin_turev = not birebir_yaygin and any(len(h) >= 4 and h in YAYGIN_PAROLALAR for h in harf_kisimlari)
    yaygin = birebir_yaygin or yaygin_turev
    sozluk_kelimesi = max((k for k in YAYGIN_KELIMELER if any(k in h for h in harf_kisimlari)),
                          key=len, default=None)
    if not yaygin and sozluk_kelimesi:
        ceza("yaygin_kelime", f"Yaygın bir kelime içeriyor ({sozluk_kelimesi})", 30)
    if any(p in h for p in _kisisel_parcalar(ad_soyad, eposta) for h in harf_kisimlari):
        ceza("kisisel_bilgi", "Adınızı veya e-postanızı içeriyor", 30)
    if _klavye_deseni_var(sade):
        ceza("klavye", "Klavye deseni içeriyor (ör. qwer, asdf)", 15)
    if parola.isdigit():
        ceza("sadece_rakam", "Yalnızca rakamlardan oluşuyor", 15)
    if _ardisik_var(kucuk):
        ceza("ardisik", "Ardışık dizi içeriyor (ör. abc, 123)", 10)
    if re.search(r"(.)\1\1", parola):
        ceza("tekrar", "Aynı karakter art arda tekrar ediyor (ör. aaa)", 10)
    if re.search(r"(19\d\d|20[0-3]\d)", parola):
        ceza("yil", "Yıl/tarih içeriyor", 10)

    skor -= sum(-c["puan"] for c in cezalar)

    # --- iş kuralları (üst sınırlar)
    kurallar = []
    if birebir_yaygin:
        bulgular.add("yaygin_parola")
        skor = min(skor, 5)
        kurallar.append("En yaygın parolalar listesinde: skor en fazla 5.")
    elif yaygin_turev:
        bulgular.add("yaygin_parola")
        skor = min(skor, 15)
        kurallar.append("Yaygın bir parolaya yalnızca rakam/sembol eklenmiş: skor en fazla 15.")
    if farkli < 5:
        skor = min(skor, 30)
        kurallar.append("5'ten az farklı karakter: skor en fazla 30.")
    if uzunluk < 8:
        skor = min(skor, 30)
        kurallar.append("8 karakterden kısa: skor en fazla 30.")
    elif uzunluk < 12:
        skor = min(skor, 69)
        kurallar.append("12 karakterden kısa: 'güçlü' olamaz (en fazla 69).")
    skor = max(0, min(100, skor))

    entropi = entropi_hesapla(uzunluk, siniflar)
    # Kırılma süresi için "etkin entropi": saldırgan desenleri ve sözlükleri bildiği için
    #  - sözlük kelimesi tek bir tahmin birimi sayılır (~10 bit, birkaç bin kelimelik sözlük)
    #  - tekrar eden karakterlerde yalnızca farklı karakterler sayılır
    #  - diğer her desen 12 bit düşürür
    etkin_entropi = entropi
    if sozluk_kelimesi:
        etkin_entropi = entropi_hesapla(uzunluk - len(sozluk_kelimesi), siniflar) + 10
    etkin_entropi = min(etkin_entropi, entropi_hesapla(farkli, siniflar) + round(math.log2(uzunluk)))
    diger = bulgular - {"yaygin_kelime", "yaygin_parola", "tekrar"}
    etkin_entropi = max(0, etkin_entropi - 12 * len(diger))
    return {
        "uzunluk": uzunluk,
        **siniflar,
        "guc_skoru": skor,
        "guc_seviyesi": seviye_belirle(skor),
        "entropi_bit": entropi,
        "kirilma_suresi": kirilma_suresi(etkin_entropi, yaygin),
        "olcutler": olcutler,
        "cezalar": cezalar,
        "kurallar": kurallar,
        "bulgular": sorted(bulgular),
    }


# ----------------------------------------------------------------- öneri kuralları

def oneri_kodlari_sec(olcum, en_fazla=5):
    """Ölçümlere göre öneri kodlarını öncelik sırasıyla seçer (öneri kataloğundaki kodlar).
    Hem gerçek analizlerde hem örnek veri üretiminde kullanılır (tek kaynak)."""
    bulgular = set(olcum.get("bulgular", []))
    kodlar = []

    def ekle(kosul, kod):
        if kosul and kod not in kodlar:
            kodlar.append(kod)

    ekle(olcum.get("sizinti_sayisi", 0) > 0, "SIZINTI_DEGISTIR")
    ekle(bulgular & {"yaygin_parola", "yaygin_kelime"}, "YAYGIN_PAROLA")
    ekle("kisisel_bilgi" in bulgular, "KISISEL_BILGI")
    ekle(olcum["uzunluk"] < 12, "UZUNLUK_ARTIR")
    ekle(bulgular & {"klavye", "ardisik", "tekrar", "yil", "sadece_rakam"}, "DESEN_KACIN")
    ekle(not olcum["ozel_karakter"], "OZEL_KARAKTER")
    ekle(not olcum["buyuk_harf"], "BUYUK_HARF_EKLE")
    ekle(not olcum["rakam"], "RAKAM_EKLE")
    ekle(olcum["uzunluk"] < 16, "PAROLA_CUMLESI")
    ekle(True, "IKI_FAKTOR")
    ekle(True, "PAROLA_YONETICI")
    return kodlar[:en_fazla]
