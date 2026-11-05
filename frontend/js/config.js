// Backend adresi.
// - Frontend ayrı bir sunucudan açıldıysa (yerelde: python -m http.server 8000) backend 5000 portundadır.
// - Canlı sürümde ve "python run.py" ile http://127.0.0.1:5000 açıldığında frontend'i backend'in
//   kendisi sunar; bu durumda API aynı adresin /api yolundadır.
const API_URL = location.port === "8000"
  ? `${location.protocol}//${location.hostname}:5000/api`
  : "/api";
