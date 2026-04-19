# Plan Projektu: Testowa Strona Gazety/Bloga

## Data utworzenia: 2026-02-07 | Ostatnia aktualizacja: 2026-04-19

---

## 1. CELE PROJEKTU

### Cel główny
Stworzenie testowej instancji strony internetowej dla lewackiej gazety.

### Cele szczegółowe
- [x] Utworzenie planu działania
- [x] Wybór generatora statycznego (Jekyll vs Hugo)
- [x] Konfiguracja GitHub Pages
- [x] Integracja Decap CMS
- [x] Implementacja uwierzytelniania przez DecapBridge
- [x] Przygotowanie architektury umożliwiającej łatwą zmianę metody uwierzytelniania
- [x] Stworzenie przykładowej struktury treści
- [ ] Testowanie z wieloma użytkownikami

---

## 2. WYMAGANIA TECHNICZNE

### Hosting i infrastruktura
- **Hosting**: GitHub Pages (standard lub dla organizacji)
- **Generator**: Jekyll LUB Hugo
- **CMS**: Decap CMS (dawniej Netlify CMS)
- **Uwierzytelnianie**: DecapBridge (z możliwością łatwej zmiany)
- **Koszt**: 100% darmowe rozwiązania

### Wymagania funkcjonalne
- Obsługa do 50 redaktorów
- System ról i uprawnień
- Łatwa edycja treści przez panel CMS
- Responsywny design
- Wsparcie dla kategorii i tagów
- System komentarzy (opcjonalnie)

---

## 3. ANALIZA TECHNOLOGII

### Jekyll vs Hugo - Porównanie

#### Jekyll
**Zalety:**
- Natywne wsparcie GitHub Pages
- Duża społeczność i dojrzałość
- Łatwa integracja z Decap CMS

**Wady:**
- Wolniejsze buildowanie przy dużej liczbie postów
- Wymaga Ruby w lokalnym środowisku

#### Hugo
**Zalety:**
- Bardzo szybkie buildowanie
- Jeden binarny plik (łatwa instalacja)
- Bogaty system szablonów
- Lepsza wydajność przy dużych projektach

**Wady:**
- Wymaga dodatkowej konfiguracji GitHub Actions dla deploymentu
- Nieco bardziej złożona składnia szablonów

**REKOMENDACJA**: Hugo - ze względu na:
- Lepszą skalowalność
- Szybsze buildowanie
- Lepszą wydajność w długim terminie

### Decap CMS
- Open-source, Git-based CMS
- Przechowuje treści jako pliki w repo
- Wsparcie dla różnych backend'ów uwierzytelniania
- Doskonała integracja z generatorami statycznymi

### DecapBridge
- Serwer proxy dla uwierzytelniania OAuth
- Bezpłatny tier dostępny
- Łatwa konfiguracja
- **Modułowa architektura** - łatwa wymiana na:
  - GitHub OAuth App (własna implementacja)
  - External OAuth providers

---

## 4. ARCHITEKTURA PROJEKTU

### Struktura katalogów (Hugo)
```
medium-test/
├── hugo.toml                   # Główna konfiguracja Hugo
├── compress-image.html         # Standalone narzędzie kompresji (poza drzewem Hugo)
├── content/
│   ├── artykuly/               # Artykuły
│   ├── wydania/                # Wydania (slug: YYYY-N.md)
│   ├── autorzy/                # Profile autorów
│   ├── pages/                  # Strony statyczne
│   └── tags/                   # Tagi
├── static/
│   ├── admin/
│   │   └── index.html          # Decap CMS + custom widgety (focal-point, kompresja)
│   ├── config.yml              # Konfiguracja Decap CMS
│   └── css/
│       ├── style.css           # Główny CSS
│       └── style-magazine.css  # Alternatywny układ.
├── assets/
│   └── images/uploads/         # Obrazki uploadowane przez CMS
├── layouts/
│   ├── _default/               # Bazowe layouty (baseof, list, single)
│   ├── wydania/                # Układ wydania
│   ├── autorzy/                # Układ strony autora
│   ├── pages/                  # Układ stron statycznych (O nas)
│   ├── partials/               # banner-image, card-image, focal-vars, image, team-card
│   └── index.html              # Strona główna
├── tests/
│   ├── reference-integrity/    # Testy integralności linków (Go)
│   └── test-local-server.sh    # Testy lokalne.
└── .github/
    └── workflows/
        └── deploy.yml          # GitHub Actions dla Hugo
```

### Warstwa uwierzytelniania - Architektura modularna
```
┌─────────────────┐
│   Decap CMS     │
└────────┬────────┘
         │
         │ (konfiguracja backend)
         ▼
┌─────────────────────────────┐
│  Auth Abstraction Layer     │
│  (config.yml)               │
└────────┬────────────────────┘
         │
         │ (wybór providera)
         ▼
┌────────────────────────────────────────┐
│  Provider 1: DecapBridge (default)     │
│  Provider 2: GitHub OAuth              │
└────────────────────────────────────────┘
```

---

## 5. PLAN IMPLEMENTACJI

### Faza 1: Inicjalizacja projektu (Priorytet: WYSOKI)
- [x] Inicjalizacja Hugo w katalogu
- [x] Utworzenie struktury folderów
- [x] Konfiguracja podstawowa hugo.toml
- [x] Wybór/stworzenie motywu dla gazety (własny motyw w layouts/)

### Faza 2: GitHub Pages Setup (Priorytet: WYSOKI)
- [x] Utworzenie GitHub repository
- [x] Konfiguracja GitHub Actions dla Hugo (.github/workflows/deploy.yml)
- [x] Setup GitHub Pages (deploy-pages action)
- [x] Test deployment
- [ ] Dodać długookresowy klucz do testowego i do produkcyjnego CMS-a: https://github.com/settings/personal-access-tokens

### Faza 3: Decap CMS Integration (Priorytet: ŚREDNI)
- [x] Instalacja Decap CMS
- [x] Konfiguracja static/config.yml
- [x] Definicja kolekcji (posts, editions, authors, pages)
- [x] Konfiguracja widgetów i pól (focal-point, sources-editor, citekey, relation)
- [x] Setup editorial workflow
- [x] Fix: focal-point widget — aktualizacja obrazka bez przeładowania strony (DOM polling zamiast stale props); działa dla artykułów i wydań
- [x] Model danych wydań: każde wydanie jest osobnym plikiem (np. `content/wydania/wiosna-2026.md`) dostępnym pod `/wydania/wiosna-2026/`, bez `_index.md`
- [x] Kompresja obrazków w przeglądarce przed uploadem do repozytorium (browser-image-compression, max 0.5 MB / 2000 px, przechwycenie `<input type="file">` w fazie capture przed DecapCMS)
- [x] Osobne narzędzie `compress-image.html` do ręcznej kompresji partii obrazków (JSZip)

### Faza 4: Uwierzytelnianie (Priorytet: ŚREDNI)
- [x] Konfiguracja DecapBridge jako domyślny backend
- [ ] Przygotowanie dokumentacji zamiany providera
- [ ] Utworzenie plików konfiguracyjnych dla alternatywnych metod
- [x] Testowanie przepływu logowania (wielokrotne PR-y przez CMS)

### Faza 5: Content & Design (Priorytet: NISKI)
- [x] Stworzenie przykładowych artykułów
- [-] Konfiguracja ról i uprawnień (obecnie tylko editorial workflow, bez ról per-user). Niemożliwe w DecapBridge, wymaga kont na GitHubie, więc odkładamy na zaś.
- [x] Dostosowanie motywu wizualnego (typografia, ciemny motyw, responsywność, nawigacja)
- [x] Układ alternatywny (`style-magazine.css`) z guzikiem, stan w localStorage
- [x] Kadrowanie obrazków
- [x] Dodanie nawigacji i menu
- [x] Strona kontakt (dodana do `content/pages/about.md`)
- [x] Lista wszystkich wydań (strona `/wydania/`) — obsługiwana przez `layouts/_default/list.html`
- [x] `layouts/wydania/single.html` — strona wydania: okładka, artykuł główny, pozostałe artykuły
- [x] W layoucie artykułu pokazać przynależność do wydania (z linkiem) — link w `article-meta` via `site.GetPage`
- [ ] Zdecydować i zaimplementować strategię strony głównej: najnowsze wydanie vs. lista artykułów
- [x] Autorzy: link z artykułu do profilu autora — pole `author` w frontmatter artykułu zawiera nazwę pliku autora, szablon szuka strony przez `site.GetPage "/autorzy/:slug"` (zamiast taksonomii Hugo)
- [x] Autorzy: strona autora z bio i listą jego artykułów — `layouts/autorzy/single.html`
- [x] Autorzy: zdjęcie w karcie redakcji (`team-card.html`) i na stronie profilu

### Faza 6: Testing & Documentation (Priorytet: NISKI)
- [x] Testowanie workflow redakcyjnego (wielokrotne PR-y przez CMS)
- [x] Testy integralności linków — relacje artykuł↔wydanie↔autor
- [ ] Testowanie z wieloma użytkownikami jednocześnie
- [ ] Dokumentacja dla redaktorów
- [x] Dokumentacja techniczna (Makefile, DECAP_CMS.md, DEPLOY_GITHUB.md)
- [ ] Utworzenie przewodnika po zmianie auth providera
- [ ] BackstopJS w CI (dodać krok w `.github/workflows/deploy.yml`)

---

## 6. KONFIGURACJA UWIERZYTELNIANIA

### DecapBridge (domyślnie)
```yaml
backend:
  name: github
  repo: owner/repo
  branch: main
  base_url: https://decapbridge.example.com
  auth_endpoint: auth
```

### Łatwa zamiana na GitHub OAuth (własny)
```yaml
backend:
  name: github
  repo: owner/repo
  branch: main
  # Wymaga GitHub OAuth App
```

---

## 7. KOSZTY I LIMITY (wszystko darmowe)

### GitHub Pages
- ✓ Darmowy hosting
- ✓ Bandwidth: 100GB/miesiąc
- ✓ Build: 10 builds/hour
- ✓ Limit rozmiaru repo: 1GB (zalecane)

### DecapBridge
- ✓ Darmowy tier dostępny
- ✓ Alternatywa: własna instancja na Vercel/Netlify

### Hugo
- ✓ 100% darmowy, open-source

### Decap CMS
- ✓ 100% darmowy, open-source

---

## 8. RYZYKA I MITYGACJA

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|--------|-------------------|-------|-----------|
| DecapBridge przestanie być darmowy | Średnie | Wysoki | Architektura modularna - łatwa zamiana na inny provider |
| Przekroczenie limitów GitHub Pages | Niskie | Średni | Monitoring użycia; kompresja obrazków zaimplementowana w CMS (max 0.5 MB/plik) |
| Konflikty przy jednoczesnej edycji | Średnie | Średni | Editorial workflow w Decap CMS |
| Zbyt wolne buildowanie | Niskie | Niski | Hugo jest bardzo szybki |

---

## 9. METRYKI SUKCESU

- [x] Strona dostępna publicznie na GitHub Pages
- [x] Decap CMS funkcjonalny z panelem administracyjnym
- [x] Udane logowanie przez DecapBridge
- [x] Możliwość dodania/edycji/usunięcia artykułu przez CMS
- [x] Responsywny design działa na mobile/tablet/desktop
- [ ] Dokumentacja umożliwia zamianę auth w <30 minut
- [ ] Build time <30 sekund dla 100 artykułów (nie testowane przy dużej liczbie postów)

---

### Przydatne repozytoria
- Hugo Themes: https://themes.gohugo.io/
- Decap CMS Templates: https://decapcms.org/docs/examples/

