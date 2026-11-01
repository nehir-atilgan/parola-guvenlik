// Backend ile konuşan tek dosya. Sayfalar backend'e doğrudan değil, bu fonksiyonlar üzerinden erişir.
const api = {
  async istek(yol, secenekler = {}) {
    // Content-Type yalnızca gövde gönderilirken eklenir (gereksiz CORS ön-isteğini önler).
    const basliklar = secenekler.body ? { "Content-Type": "application/json" } : {};
    const yanit = await fetch(API_URL + yol, { ...secenekler, headers: basliklar });
    if (!yanit.ok) throw new Error("Sunucu hatası: " + yanit.status);
    return yanit.json();
  },

  saglik() {
    return this.istek("/saglik");
  },

  moduller() {
    return this.istek("/moduller");
  },
};
