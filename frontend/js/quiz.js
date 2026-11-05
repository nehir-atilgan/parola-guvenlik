// Farkındalık Quizi sayfası.
// Doğru cevaplar tarayıcıda YOKTUR: sunucu cevapları ancak "gönder"den sonra açıklar.
// Verilen cevaplar sekme kapanana kadar sessionStorage'da tutulur (sayfa yenilense de kaybolmaz).

const $ = (id) => document.getElementById(id);
const eleman = (etiket, metin, sinif) => {
  const e = document.createElement(etiket);
  if (metin !== undefined) e.textContent = metin;
  if (sinif) e.className = sinif;
  return e;
};

const durum = { deneme: null, cevaplar: {}, aktif: 0, sayacId: null };

function ekran(ad) {
  for (const id of ["giris-ekrani", "soru-ekrani", "sonuc-ekrani"]) $(id).hidden = id !== ad;
  $("yukleniyor").hidden = true;
  window.scrollTo(0, 0);
}

function hataGoster(metin) {
  $("mesaj").textContent = metin;
  $("mesaj").hidden = !metin;
}

// SQLite UTC zamanını ("2026-11-05 20:12:49") tarayıcı saatine çevirir.
const utc = (t) => new Date(t.replace(" ", "T") + "Z");
const tarihMetni = (t) => utc(t).toLocaleString("tr-TR", { dateStyle: "short", timeStyle: "short" });

// ------------------------------------------------------------ cevapları hatırlama

const anahtar = () => "quiz-cevaplar-" + durum.deneme.deneme_id;
function cevaplariKaydet() {
  try { sessionStorage.setItem(anahtar(), JSON.stringify(durum.cevaplar)); } catch {}
}
function cevaplariYukle() {
  try { return JSON.parse(sessionStorage.getItem(anahtar())) || {}; } catch { return {}; }
}

// ------------------------------------------------------------ 1) giriş ekranı

async function girisEkrani() {
  ekran("giris-ekrani");
  const gecmis = await api.quizGecmisi();
  const govde = $("gecmis");
  govde.innerHTML = "";
  gecmis.forEach((g) => {
    const tr = document.createElement("tr");
    tr.append(eleman("td", tarihMetni(g.tarih)), eleman("td", String(g.puan)), eleman("td", `${g.dogru_sayisi} / ${g.soru_sayisi}`));
    const td = document.createElement("td");
    if (g.deneme_id) {
      const a = eleman("a", "Ayrıntılar", "kucuk");
      a.href = "quiz.html?deneme=" + g.deneme_id;
      td.appendChild(a);
    }
    tr.appendChild(td);
    govde.appendChild(tr);
  });
  $("gecmis-bolum").hidden = gecmis.length === 0;
}

// ------------------------------------------------------------ 2) soru ekranı

function soruEkrani(deneme) {
  durum.deneme = deneme;
  durum.cevaplar = cevaplariYukle();
  const ilkBos = deneme.sorular.findIndex((s) => !durum.cevaplar[s.soru_id]);
  durum.aktif = ilkBos === -1 ? deneme.sorular.length - 1 : ilkBos;
  history.replaceState(null, "", "quiz.html?deneme=" + deneme.deneme_id);
  ekran("soru-ekrani");
  sayaciBaslat(utc(deneme.son_teslim));
  soruyuCiz();
}

function soruyuCiz() {
  const sorular = durum.deneme.sorular;
  const soru = sorular[durum.aktif];
  const cevaplanan = sorular.filter((s) => durum.cevaplar[s.soru_id]).length;

  $("ilerleme-metin").textContent = `Soru ${durum.aktif + 1} / ${sorular.length} · ${cevaplanan} cevaplandı`;
  $("ilerleme").style.width = (cevaplanan / sorular.length) * 100 + "%";
  $("soru-metin").textContent = soru.metin;

  const kutu = $("secenekler");
  kutu.innerHTML = "";
  soru.secenekler.forEach((s) => {
    const label = eleman("label", undefined, "secenek");
    const input = document.createElement("input");
    input.type = "radio";
    input.name = "secenek";
    input.value = s.id;
    input.checked = durum.cevaplar[soru.soru_id] === s.id;
    input.addEventListener("change", () => {
      durum.cevaplar[soru.soru_id] = s.id;
      cevaplariKaydet();
      soruyuCiz();
    });
    label.append(input, eleman("span", s.metin));
    kutu.appendChild(label);
  });

  const son = durum.aktif === sorular.length - 1;
  $("onceki").disabled = durum.aktif === 0;
  $("sonraki").hidden = son;
  $("gonder").hidden = !son;
  $("gonder").disabled = cevaplanan < sorular.length;
  $("gonder").textContent = cevaplanan < sorular.length
    ? `Cevapları gönder (${sorular.length - cevaplanan} boş)` : "Cevapları gönder";

  const noktalar = $("soru-noktalari");
  noktalar.innerHTML = "";
  sorular.forEach((s, i) => {
    const b = eleman("button", String(i + 1), "nokta");
    b.type = "button";
    if (durum.cevaplar[s.soru_id]) b.classList.add("dolu");
    if (i === durum.aktif) b.classList.add("aktif");
    b.setAttribute("aria-label", `Soru ${i + 1}` + (durum.cevaplar[s.soru_id] ? " (cevaplandı)" : ""));
    b.addEventListener("click", () => { durum.aktif = i; soruyuCiz(); });
    noktalar.appendChild(b);
  });
}

function sayaciBaslat(sonTeslim) {
  clearInterval(durum.sayacId);
  const guncelle = () => {
    const kalan = Math.max(0, Math.floor((sonTeslim - Date.now()) / 1000));
    const dk = String(Math.floor(kalan / 60)).padStart(2, "0");
    const sn = String(kalan % 60).padStart(2, "0");
    $("sayac").textContent = `⏱ ${dk}:${sn}`;
    $("sayac").classList.toggle("az", kalan < 120);
    if (kalan === 0) {
      clearInterval(durum.sayacId);
      hataGoster("Süre doldu. Bu deneme artık gönderilemez; yeni bir quiz başlatabilirsiniz.");
      $("gonder").disabled = true;
    }
  };
  guncelle();
  durum.sayacId = setInterval(guncelle, 1000);
}

// ------------------------------------------------------------ 3) sonuç ekranı

function sonucEkrani(s) {
  clearInterval(durum.sayacId);
  history.replaceState(null, "", "quiz.html?deneme=" + s.deneme_id);
  const seviye = s.puan >= 70 ? "guclu" : s.puan >= 50 ? "orta" : "zayif";

  $("puan").textContent = s.puan;
  $("dogru-sayisi").textContent = `${s.dogru_sayisi} / ${s.soru_sayisi} doğru`;
  $("dogru-sayisi").className = "seviye " + seviye;
  $("puan-cubuk").className = seviye;
  $("puan-cubuk").style.width = s.puan + "%";
  $("degerlendirme").textContent = s.degerlendirme;

  const tekrar = $("tekrar-konular");
  tekrar.innerHTML = "";
  s.tekrar_okunacak_konular.forEach((k) => {
    const li = document.createElement("li");
    const a = eleman("a", k.baslik);
    a.href = "rehber.html?konu=" + encodeURIComponent(k.slug);
    li.appendChild(a);
    tekrar.appendChild(li);
  });
  $("tekrar-bolum").hidden = s.tekrar_okunacak_konular.length === 0;

  const liste = $("degerlendirme-listesi");
  liste.innerHTML = "";
  s.sorular.forEach((q) => {
    const li = eleman("li", undefined, q.dogru_mu ? "dogru" : "yanlis");
    li.appendChild(eleman("strong", q.soru));
    li.appendChild(eleman("p", (q.dogru_mu ? "✓ " : "✗ ") + "Cevabınız: " + q.verilen, "kucuk cevap"));
    if (!q.dogru_mu) li.appendChild(eleman("p", "Doğru cevap: " + q.dogru_cevap, "kucuk dogru-cevap"));
    const aciklama = eleman("p", q.aciklama + " ", "kucuk soluk");
    const a = eleman("a", "Konu: " + q.konu.baslik);
    a.href = "rehber.html?konu=" + encodeURIComponent(q.konu.slug);
    aciklama.appendChild(a);
    li.appendChild(aciklama);
    liste.appendChild(li);
  });
  ekran("sonuc-ekrani");
}

// ------------------------------------------------------------ olaylar

async function quizBaslat() {
  hataGoster("");
  $("baslat").disabled = true;
  try {
    soruEkrani(await api.quizBaslat());
  } catch (hata) {
    hataGoster(hata.message);
  } finally {
    $("baslat").disabled = false;
  }
}

$("baslat").addEventListener("click", quizBaslat);
$("yeni-quiz").addEventListener("click", quizBaslat);
$("onceki").addEventListener("click", () => { durum.aktif--; soruyuCiz(); });
$("sonraki").addEventListener("click", () => { durum.aktif++; soruyuCiz(); });

$("soru-formu").addEventListener("submit", async (e) => {
  e.preventDefault();
  $("gonder").disabled = true;
  hataGoster("");
  try {
    const sonuc = await api.quizGonder(durum.deneme.deneme_id, durum.cevaplar);
    try { sessionStorage.removeItem(anahtar()); } catch {}
    sonucEkrani(sonuc);
  } catch (hata) {
    hataGoster(hata.message);
    $("gonder").disabled = false;
  }
});

(async () => {
  const giris = await oturum.sayfayiKoru(); // giriş yoksa giris.html'e yönlendirir
  if (!giris) return;
  const denemeId = Number(new URLSearchParams(location.search).get("deneme"));
  try {
    if (denemeId) {
      const d = await api.quizGetir(denemeId);
      d.durum === "tamamlandi" ? sonucEkrani(d) : soruEkrani(d);
    } else {
      await girisEkrani();
    }
  } catch (hata) {
    await girisEkrani();
    hataGoster(hata.message);
  }
})();
