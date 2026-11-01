// Ana sayfa: backend durumunu ve modül kartlarını gösterir.
document.addEventListener("DOMContentLoaded", async () => {
  const durum = document.getElementById("backend-durum");
  const kutu = document.getElementById("moduller");

  try {
    await api.saglik();
    durum.textContent = "● Backend bağlı";
    durum.classList.add("bagli");

    const moduller = await api.moduller();
    kutu.innerHTML = "";
    moduller.forEach((m) => kutu.appendChild(kartOlustur(m)));
  } catch (hata) {
    durum.textContent = "● Backend'e ulaşılamadı";
    durum.classList.add("hata");
    kutu.innerHTML =
      '<p class="uyari">Backend çalışmıyor. <code>backend</code> klasöründe <code>python run.py</code> komutunu çalıştırın.</p>';
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
  rozet.textContent = "Yakında";

  kart.append(baslik, aciklama, rozet);
  return kart;
}
