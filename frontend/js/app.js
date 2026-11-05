// Ana sayfa: backend durumunu ve modül kartlarını gösterir.
document.addEventListener("DOMContentLoaded", async () => {
  const durum = document.getElementById("backend-durum");
  const kutu = document.getElementById("moduller");

  try {
    const saglik = await api.saglik();
    durum.textContent = "● Backend bağlı · sürüm " + saglik.surum;
    durum.classList.add("bagli");

    const moduller = await api.moduller();
    kutu.innerHTML = "";
    moduller.forEach((m) => kutu.appendChild(kartOlustur(m)));
  } catch (hata) {
    durum.textContent = "● Backend'e ulaşılamadı";
    durum.classList.add("hata");
    kutu.innerHTML =
      location.hostname === "127.0.0.1" || location.hostname === "localhost"
        ? '<p class="uyari">Backend çalışmıyor. <code>backend</code> klasöründe <code>python run.py</code> komutunu çalıştırın.</p>'
        : '<p class="uyari">Sunucu şu anda uyanıyor olabilir (ücretsiz sunucu bir süre kullanılmayınca uykuya geçer). Yaklaşık bir dakika sonra sayfayı yenileyin.</p>';
  }
});

function kartOlustur(m) {
  const kart = document.createElement("article");
  kart.className = "kart";

  const baslik = document.createElement("h2");
  baslik.textContent = m.ad;
  const aciklama = document.createElement("p");
  aciklama.textContent = m.aciklama;
  const rozet = document.createElement("span");
  rozet.className = "rozet";
  rozet.textContent = m.sayfa ? "Hazır" : "Yakında";
  kart.append(baslik, aciklama, rozet);

  if (m.sayfa) {
    // Hazır modüller tıklanabilir bir kart olur.
    const baglanti = document.createElement("a");
    baglanti.href = m.sayfa;
    baglanti.className = "kart kart-baglanti";
    baglanti.append(...kart.childNodes);
    rozet.classList.add("hazir");
    return baglanti;
  }
  return kart;
}
