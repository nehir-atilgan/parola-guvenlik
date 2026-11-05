// Backend ile konuşan tek dosya. Sayfalar backend'e doğrudan değil, bu fonksiyonlar üzerinden erişir.

class ApiHatasi extends Error {
  constructor(mesaj, durum) {
    super(mesaj);
    this.durum = durum; // 401: giriş yok/süre doldu, 403: yetki yok
  }
}

const api = {
  async istek(yol, { yontem = "GET", govde } = {}) {
    const basliklar = {};
    // Content-Type yalnızca gövde gönderilirken eklenir (gereksiz CORS ön-isteğini önler).
    if (govde !== undefined) basliklar["Content-Type"] = "application/json";
    const token = oturum.token();
    if (token) basliklar["Authorization"] = "Bearer " + token;

    const yanit = await fetch(API_URL + yol, {
      method: yontem,
      headers: basliklar,
      body: govde !== undefined ? JSON.stringify(govde) : undefined,
    });
    const veri = await yanit.json().catch(() => ({}));
    if (!yanit.ok) throw new ApiHatasi(veri.hata || "Sunucu hatası: " + yanit.status, yanit.status);
    return veri;
  },

  saglik: () => api.istek("/saglik"),
  moduller: () => api.istek("/moduller"),

  // Kimlik doğrulama
  kayit: (ad_soyad, eposta, parola) => api.istek("/kayit", { yontem: "POST", govde: { ad_soyad, eposta, parola } }),
  giris: (eposta, parola) => api.istek("/giris", { yontem: "POST", govde: { eposta, parola } }),
  cikis: () => api.istek("/cikis", { yontem: "POST" }),
  ben: () => api.istek("/ben"),

  // Parola Gücü Analizi
  analiz: (parola, kaydet = false) => api.istek("/analiz", { yontem: "POST", govde: { parola, kaydet } }),
  analizlerim: () => api.istek("/analizler"),
  analizSil: (id) => api.istek(`/analizler/${id}`, { yontem: "DELETE" }),

  // Farkındalık Rehberi ve Quiz
  rehber: () => api.istek("/rehber"),
  rehberKonusu: (slug) => api.istek("/rehber/" + encodeURIComponent(slug)),
  quizBaslat: () => api.istek("/quiz/baslat", { yontem: "POST" }),
  quizGetir: (id) => api.istek(`/quiz/${id}`),
  quizGonder: (id, cevaplar) => api.istek(`/quiz/${id}/gonder`, { yontem: "POST", govde: { cevaplar } }),
  quizGecmisi: () => api.istek("/quiz/gecmis"),

  // Yönetici
  kullanicilar: () => api.istek("/yonetici/kullanicilar"),
  rolDegistir: (id, rol) => api.istek(`/yonetici/kullanicilar/${id}/rol`, { yontem: "PATCH", govde: { rol } }),
};
