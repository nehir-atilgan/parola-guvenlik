// Parola Gücü Analizi sayfası.
// Parola yalnızca analiz isteğinde backend'e gönderilir; tarayıcıda da hiçbir yere (localStorage vb.) yazılmaz.

const SEVIYE = { zayif: "Zayıf", orta: "Orta", guclu: "Güçlü" };
const SINIF = { kucuk_harf: "Küçük harf", buyuk_harf: "Büyük harf", rakam: "Rakam", ozel_karakter: "Özel karakter" };

const $ = (id) => document.getElementById(id);
const form = $("analiz-formu");
const girdi = $("parola");

function mesajGoster(metin, tur) {
  $("mesaj").textContent = metin;
  $("mesaj").className = "mesaj " + tur;
  $("mesaj").hidden = false;
}

function eleman(etiket, metin, sinif) {
  const e = document.createElement(etiket);
  if (metin !== undefined) e.textContent = metin;
  if (sinif) e.className = sinif;
  return e;
}

// ------------------------------------------------------------ sonucu göster

function sonucuGoster(s) {
  $("skor").textContent = s.guc_skoru;
  $("seviye").textContent = SEVIYE[s.guc_seviyesi];
  $("seviye").className = "seviye " + s.guc_seviyesi;
  $("cubuk-dolgu").style.width = s.guc_skoru + "%";
  $("cubuk-dolgu").className = s.guc_seviyesi;
  document.querySelector(".cubuk").setAttribute("aria-valuenow", s.guc_skoru);
  $("sure").textContent = s.kirilma_suresi;
  $("entropi").textContent = s.entropi_bit;

  const siniflar = $("siniflar");
  siniflar.innerHTML = "";
  Object.entries(SINIF).forEach(([anahtar, ad]) =>
    siniflar.appendChild(eleman("li", (s[anahtar] ? "✓ " : "✗ ") + ad, s[anahtar] ? "var" : "yok")));

  // Ölçütler + cezalar: skorun nereden geldiğini satır satır gösterir
  const govde = $("olcutler");
  govde.innerHTML = "";
  s.olcutler.forEach((o) => {
    const tr = document.createElement("tr");
    tr.append(eleman("td", o.ad), eleman("td", o.aciklama, "soluk"), eleman("td", `+${o.puan} / ${o.en_fazla}`, "sag"));
    govde.appendChild(tr);
  });
  s.cezalar.forEach((c) => {
    const tr = document.createElement("tr");
    tr.className = "ceza";
    tr.append(eleman("td", "Ceza"), eleman("td", c.neden), eleman("td", String(c.puan), "sag"));
    govde.appendChild(tr);
  });
  const kurallar = $("kurallar");
  kurallar.innerHTML = "";
  s.kurallar.forEach((k) => kurallar.appendChild(eleman("li", "Kural: " + k)));

  const oneriler = $("oneriler");
  oneriler.innerHTML = "";
  s.oneriler.forEach((o) => {
    const li = document.createElement("li");
    li.append(eleman("strong", o.baslik), eleman("p", o.aciklama, "soluk kucuk"));
    oneriler.appendChild(li);
  });

  $("sonuc").hidden = false;
}

// ------------------------------------------------------------ geçmiş

async function gecmisiYukle() {
  const govde = $("gecmis");
  const kayitlar = await api.analizlerim();
  govde.innerHTML = "";
  if (kayitlar.length === 0) {
    const tr = document.createElement("tr");
    const td = eleman("td", "Henüz kaydedilmiş analiz yok.", "soluk");
    td.colSpan = 6;
    tr.appendChild(td);
    govde.appendChild(tr);
  }
  kayitlar.forEach((a) => {
    const tr = document.createElement("tr");
    const sil = eleman("button", "Sil", "metin-btn kucuk");
    sil.type = "button";
    sil.addEventListener("click", async () => {
      try {
        await api.analizSil(a.id);
        await gecmisiYukle();
      } catch (hata) {
        mesajGoster(hata.message, "hata");
      }
    });
    const silTd = document.createElement("td");
    silTd.appendChild(sil);
    tr.append(
      eleman("td", new Date(a.tarih.replace(" ", "T") + "Z").toLocaleString("tr-TR")),
      eleman("td", String(a.guc_skoru)),
      eleman("td", SEVIYE[a.guc_seviyesi], "seviye-metin " + a.guc_seviyesi),
      eleman("td", a.uzunluk + " karakter"),
      eleman("td", a.entropi_bit + " bit"),
      silTd,
    );
    govde.appendChild(tr);
  });
  $("gecmis-bolum").hidden = false;
}

// ------------------------------------------------------------ olaylar

$("goster").addEventListener("click", () => {
  const gizli = girdi.type === "password";
  girdi.type = gizli ? "text" : "password";
  $("goster").textContent = gizli ? "Gizle" : "Göster";
  $("goster").setAttribute("aria-pressed", String(gizli));
});

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  $("mesaj").hidden = true;
  if (!girdi.value) return mesajGoster("Analiz için bir parola girin.", "hata");

  const kaydet = $("kaydet").checked && !!oturum.token();
  const btn = form.querySelector("button[type=submit]");
  btn.disabled = true;
  try {
    const sonuc = await api.analiz(girdi.value, kaydet);
    sonucuGoster(sonuc);
    if (sonuc.analiz_id) {
      mesajGoster("Sonuç geçmişinize kaydedildi (parolanın kendisi kaydedilmedi).", "basari");
      await gecmisiYukle();
    }
  } catch (hata) {
    if (hata.durum === 401 && kaydet) {
      oturum.temizle();
      location.href = "giris.html?neden=sure&donus=analiz.html";
      return;
    }
    mesajGoster(hata.message, "hata");
  } finally {
    btn.disabled = false;
  }
});

// Giriş yapmış kullanıcıya "kaydet" seçeneği ve geçmiş gösterilir; giriş yoksa sayfa yine çalışır.
document.addEventListener("DOMContentLoaded", async () => {
  if (!oturum.token()) return;
  try {
    await api.ben();
    $("kaydet-satir").hidden = false;
    $("kaydet").checked = true;
    await gecmisiYukle();
  } catch (hata) {
    if (hata.durum === 401) {
      oturum.temizle();
      menuCiz();
    }
  }
});
