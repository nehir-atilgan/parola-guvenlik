// Oturum yönetimi (tarayıcı tarafı).
//
// Token sessionStorage'da tutulur: sekme kapanınca silinir.
// ÖNEMLİ: Buradaki kontroller yalnızca kullanıcı deneyimi içindir (doğru sayfaya yönlendirme,
// menüde doğru bağlantıları gösterme). Asıl yetki kontrolünü HER istekte backend yapar;
// tarayıcıdaki kod değiştirilse bile yetkisiz veri alınamaz.

const oturum = {
  token() {
    try { return sessionStorage.getItem("token"); } catch { return null; }
  },

  kullanici() {
    try { return JSON.parse(sessionStorage.getItem("kullanici")); } catch { return null; }
  },

  kaydet(token, kullanici) {
    sessionStorage.setItem("token", token);
    sessionStorage.setItem("kullanici", JSON.stringify(kullanici));
  },

  temizle() {
    try { sessionStorage.removeItem("token"); sessionStorage.removeItem("kullanici"); } catch {}
  },

  async cikisYap() {
    try { await api.cikis(); } catch {} // backend'de oturum iptal edilir
    oturum.temizle();
    location.href = "giris.html?neden=cikis";
  },

  // Korumalı sayfaların başında çağrılır. Backend'e sorar; giriş yoksa giriş sayfasına yollar.
  // gerekliRol verilirse ve kullanıcının rolü uymuyorsa null döner (sayfa "yetkiniz yok" gösterir).
  async sayfayiKoru(gerekliRol) {
    if (!oturum.token()) {
      location.href = "giris.html?neden=giris&donus=" + encodeURIComponent(location.pathname.split("/").pop());
      return null;
    }
    try {
      const bilgi = await api.ben();
      oturum.kaydet(oturum.token(), bilgi.kullanici); // rol değişmişse güncellenir
      menuCiz();
      if (gerekliRol && bilgi.kullanici.rol !== gerekliRol) return { yetkisiz: true, bilgi };
      return { yetkisiz: false, bilgi };
    } catch (hata) {
      if (hata.durum === 401) {
        oturum.temizle();
        location.href = "giris.html?neden=sure";
        return null;
      }
      throw hata;
    }
  },
};

// Üst menü: giriş durumuna ve role göre bağlantıları gösterir.
function menuCiz() {
  const menu = document.getElementById("menu");
  if (!menu) return;
  const k = oturum.kullanici();
  const baglanti = (href, metin) => `<a href="${href}">${metin}</a>`;

  if (!k) {
    menu.innerHTML = baglanti("giris.html", "Giriş yap") + baglanti("kayit.html", "Kayıt ol");
    return;
  }
  menu.innerHTML =
    baglanti("panel.html", "Panelim") +
    (k.rol === "yonetici" ? baglanti("yonetici.html", "Yönetici") : "") +
    `<span class="kim"></span><button type="button" id="cikis-btn" class="metin-btn">Çıkış</button>`;
  menu.querySelector(".kim").textContent = k.ad_soyad;
  document.getElementById("cikis-btn").addEventListener("click", oturum.cikisYap);
}

document.addEventListener("DOMContentLoaded", menuCiz);
