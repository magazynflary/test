# Plan Testowania - Testowa Strona Gazety

## Data utworzenia: 2026-02-07

---

## Faza 1: Inicjalizacja projektu

### Test 1.1: Hugo zainstalowany i działający
```bash
hugo version
# Oczekiwane: hugo v0.155.x lub nowsze
```

### Test 1.2: Struktura projektu utworzona
```bash
ls -la
# Oczekiwane: katalogi: archetypes/, content/, layouts/, static/, themes/
# Oczekiwane: pliki: hugo.toml, .gitignore
```

### Test 1.3: Serwer lokalny działa
```bash
hugo server --buildDrafts
# Otwórz: http://localhost:1313/
# Oczekiwane: strona się wyświetla bez błędów 404
```

### Test 1.4: Git zainicjalizowany
```bash
git status
git log --oneline
# Oczekiwane: commit "Initial Hugo setup..."
```

### Kryteria sukcesu Fazy 1:
- [x] Hugo zainstalowany (sprawdzone: hugo version)
- [x] Podstawowa struktura katalogów istnieje
- [x] Konfiguracja hugo.toml poprawna
- [x] Serwer lokalny wyświetla stronę
- [x] Git repo zainicjalizowane z pierwszym commitem

---

## Faza 2: GitHub Pages Setup

### Test 2.1: GitHub repo utworzone
```bash
git remote -v
# Oczekiwane: origin https://github.com/username/repo.git
```

### Test 2.2: GitHub Actions workflow poprawny
```bash
cat .github/workflows/deploy.yml
# Sprawdź: workflow zawiera kroki: checkout, setup hugo, build, deploy
```

### Test 2.3: Test lokalnego buildu produkcyjnego
```bash
hugo --minify
ls -la public/
# Oczekiwane: katalog public/ zawiera: index.html, css/, artykuly/
```

### Test 2.4: Deployment działa
```bash
git push origin main
# Sprawdź: https://github.com/username/repo/actions
# Oczekiwane: workflow zakończony sukcesem (zielony ✓)
```

### Test 2.5: Strona dostępna publicznie
```
Otwórz: https://username.github.io/repo/
# Oczekiwane: strona wyświetla się poprawnie
# Sprawdź: CSS załadowany, linki działają
```

### Kryteria sukcesu Fazy 2:
- [x] GitHub repo istnieje i jest połączone
- [x] GitHub Actions workflow skonfigurowany
- [x] Lokalny build produkcyjny działa
- [x] Push do main trigguje deployment
- [x] Strona dostępna pod URL GitHub Pages
- [x] CSS i zasoby statyczne działają

---

## Faza 3: Decap CMS Integration

### Test 3.1: Pliki CMS utworzone
```bash
ls static/admin/index.html static/config.yml
# Oczekiwane: oba pliki istnieją.
```

### Test 3.2: Panel CMS dostępny lokalnie
```
Otwórz: http://localhost:1313/admin/
# Oczekiwane: interfejs Decap CMS się ładuje
```

### Test 3.3: Konfiguracja CMS poprawna
```bash
cat static/config.yml
# Sprawdź: backend, collections, media_folder skonfigurowane
```

### Test 3.4: Kolekcje zdefiniowane
```yaml
# W static/config.yml sprawdź istnienie (name: to identyfikator, nie etykieta UI):
collections:
  - name: "posts"     # artykuły
  - name: "editions"  # wydania
  - name: "authors"   # autorzy
  - name: "pages"
```

### Test 3.5: Editorial workflow działa
```
Panel CMS > Nowy post > Zapisz jako draft
# Oczekiwane: utworzony pull request w GitHub
```

### Test 3.6: Widget kadrowania
```
Panel CMS > Artykuł > pole "kadrowanie: baner" oraz "kadrowanie: karta"
# Oczekiwane: widget renderuje podgląd obrazka z przeciągalnym punktem.
# Oczekiwane: po zmianie obrazka punkt focal resetuje się bez przeładowania strony.
```

### Test 3.7: Kompresja obrazków
```
Panel CMS > Upload obrazka > wybierz plik >5 MB
# Oczekiwane: plik automatycznie skompresowany do <0.5 MB przed uploadem.
```

### Kryteria sukcesu Fazy 3:
- [x] Panel /admin/ dostępny
- [x] Konfiguracja static/config.yml bez błędów składni
- [x] Wszystkie kolekcje widoczne w panelu (Artykuły, Wydania, Autorzy, Strony)
- [x] Widgety edycji działają (markdown, image, date, focal-point)
- [x] Editorial workflow tworzy PR
- [x] Kompresja obrazków działa automatycznie

---

## Faza 4: Uwierzytelnianie

### Test 4.1: DecapBridge skonfigurowany
```bash
grep -A5 "backend:" static/config.yml
# Oczekiwane: base_url wskazuje na DecapBridge
```

### Test 4.2: Logowanie działa
```
Otwórz: https://username.github.io/repo/admin/
Kliknij: "Login with GitHub"
# Oczekiwane: przekierowanie do OAuth, następnie powrót do CMS
```

### Test 4.3: Autoryzacja sprawdzona
```
Po zalogowaniu sprawdź:
# Oczekiwane: widoczne kolekcje, możliwość edycji
```

### Test 4.4: Test alternatywnego providera
```
# Edytuj static/config.yml — zmień backend na GitHub OAuth (bez base_url)
# Sprawdź, czy CMS dalej działa (z innym auth)
# Przywróć DecapBridge po teście
```

### Test 4.5: Dokumentacja zamiany
```
Sprawdź sekcję "Zmiana providera uwierzytelniania" w DECAP_CMS.md.
# Oczekiwane: przykłady konfiguracji dla DecapBridge i GitHub OAuth.
```

### Kryteria sukcesu Fazy 4:
- [x] Logowanie przez DecapBridge działa
- [x] Po zalogowaniu dostęp do edycji
- [ ] Dokumentacja zamiany providera (DECAP_CMS.md ma przykłady, brak pełnego przewodnika)
- [ ] Przetestowano minimum 2 providery
- [ ] Zmiana providera zajmuje <30 minut

---

## Faza 5: Content & Design

### Test 5.1: Przykładowe artykuły
```bash
ls content/artykuly/
# Oczekiwane: minimum 5 przykładowych plików .md
```

### Test 5.2: Różne typy treści
```
Sprawdź istnienie:
- content/artykuly/*.md (artykuły)
- content/wydania/*.md (wydania, format YYYY-N.md)
- content/autorzy/*.md (profile autorów)
- content/pages/about.md (strona O nas)
```

### Test 5.3: Responsywność
```
Otwórz stronę w przeglądarce
DevTools > Toggle device toolbar
Przetestuj: Mobile (375px), Tablet (768px), Desktop (1920px)
# Oczekiwane: treść czytelna na wszystkich rozdzielczościach
```

### Test 5.4: Kategorie i tagi
```
Otwórz: http://localhost:1313/tags/
Otwórz: http://localhost:1313/categories/
# Oczekiwane: listy tagów i kategorii z linkami
```

### Test 5.5: Nawigacja
```
Sprawdź w przeglądarce:
- Menu główne: linki do strony głównej, wydań, O nas
- Linki artykuł ↔ wydanie ↔ autor działają
- Active state dla bieżącej strony
```

### Test 5.6: Układ magazynowy
```
Otwórz artykuł > kliknij przycisk toggle layoutu.
# Oczekiwane: strona przełącza się na layout magazynowy.
# Oczekiwane: po odświeżeniu ustawienie zachowane (localStorage).
```

### Test 5.7: Kadrowanie obrazków
```
Otwórz artykuł z obrazkiem banera.
# Oczekiwane: kadr banera zgodny z ustawionym kadrem.
Zmień szerokość okna (desktop/mobile).
# Oczekiwane: kadr dostosowuje się (aspect-ratio + object-position).
```

### Kryteria sukcesu Fazy 5:
- [x] 5+ przykładowych artykułów
- [x] Strony statyczne (About)
- [x] Profile autorów ze zdjęciami i listą artykułów
- [x] Responsywny design (mobile/tablet/desktop)
- [x] Nawigacja funkcjonalna (artykuł ↔ wydanie ↔ autor)
- [x] Layout magazynowy z togglem
- [x] Focal point na banerach i kartach
- [ ] Kategorie
- [x] Tagi

---

## Faza 6: Testing & Documentation

### Test 6.1: Workflow redakcyjny - pojedynczy redaktor
```
Scenariusz:
1. Zaloguj do CMS
2. Utwórz nowy post
3. Dodaj tytuł, treść, obraz
4. Zapisz jako draft
5. Opublikuj

Oczekiwane:
- Draft tworzy PR
- Publikacja merguje PR
- Artykuł pojawia się na stronie
```

### Test 6.2: Workflow redakcyjny - wielu redaktorów
```
Scenariusz:
1. Redaktor A: tworzy draft "Post A"
2. Redaktor B: tworzy draft "Post B"
3. Redaktor A: publikuje swój post
4. Sprawdź czy Post B nadal jest draftem

Oczekiwane:
- Brak konfliktów
- Każdy draft to osobny PR
```

### Test 6.3: Performance - czas buildowania
```bash
time hugo --minify
# Oczekiwane: <5 sekund dla 10 postów
# Oczekiwane: <30 sekund dla 100 postów
```

### Test 6.4: Testy integralności referencji
```bash
make test   # Uruchamia tests/reference-integrity/.
# Oczekiwane: wszystkie relacje artykuł↔wydanie↔autor są dwustronne i spójne.
```

### Test 6.5: Wizualna regresja (BackstopJS)
```bash
npx backstop test
# Oczekiwane: brak różnic powyżej progu (backstop.json).
# Przy nowym baseline: npx backstop approve.
```

### Test 6.6: Dokumentacja techniczna
```bash
ls *.md
# Oczekiwane: DECAP_CMS.md, DEPLOY_GITHUB.md, PLAN_PROJEKTU.md.
```

### Kryteria sukcesu Fazy 6:
- [x] Single-user workflow działa (wielokrotne PR przez CMS)
- [x] Testy integralności referencji przechodzą
- [ ] Multi-user workflow przetestowany (≥2 użytkowników jednocześnie)
- [ ] Build time <30s dla 100 artykułów (nie mierzony)
- [ ] Dokumentacja dla redaktorów
- [ ] Przewodnik zamiany auth providera
- [ ] BackstopJS w CI

---

## Testy End-to-End (E2E)

### E2E Test 1: Pełny cykl artykułu
```
1. Redaktor loguje się do CMS
2. Tworzy nowy artykuł z obrazem
3. Dodaje tagi i kategorię
4. Zapisuje jako draft
5. Edytor recenzuje draft
6. Redaktor publikuje
7. Artykuł pojawia się na stronie w <2 minuty

Oczekiwane: Każdy krok działa płynnie
```

### E2E Test 2: Symulacja 20 redaktorów
```
1. Utwórz 20 testowych drafts
2. Opublikuj 10 z nich jednocześnie
3. Sprawdź logi GitHub Actions
4. Sprawdź czy wszystkie 10 jest na stronie

Oczekiwane: Brak błędów, wszystkie posty widoczne
```

### E2E Test 3: Zmiana auth providera
```
1. Zanotuj czas rozpoczęcia
2. Zmień DecapBridge na Netlify Identity
3. Przetestuj logowanie
4. Zanotuj czas zakończenia

Oczekiwane: Całość <30 minut
```

---

## Checklist przed produkcją

### Podstawy
- [x] Hugo działa lokalnie
- [x] Build produkcyjny bez błędów
- [x] GitHub Pages deployment działa

### CMS
- [x] Decap CMS dostępny pod /admin/
- [x] Logowanie działa (DecapBridge)
- [x] Wszystkie kolekcje widoczne w panelu (Artykuły, Wydania, Autorzy, Strony)
- [x] Editorial workflow testowany

### Treść
- [x] 5+ przykładowych artykułów
- [x] Strona About
- [x] Profile autorów ze zdjęciami

### Design
- [x] Responsywny na mobile/tablet/desktop
- [x] CSS załadowany poprawnie (style.css + style-magazine.css)
- [x] Obrazy z focal pointem wyświetlają się poprawnie
- [x] Nawigacja artykuł ↔ wydanie ↔ autor działa

### Dokumentacja
- [ ] Przewodnik dla redaktorów
- [ ] Instrukcje zamiany auth (szkic w DECAP_CMS.md)

### Performance
- [ ] Build <30s dla 100 artykułów (nie mierzony)
- [ ] Strona ładuje się <3s
- [ ] Lighthouse score >80

---

## Narzędzia testowania

### Test lokalny
```bash
hugo server --buildDrafts
```

### Build produkcyjny
```bash
hugo --minify
```

### Test performance
```bash
time hugo --minify
```

### Test dostępności
```bash
npm install -g lighthouse
lighthouse https://username.github.io/repo/ --view
```

### Sprawdzenie linków
```bash
npm install -g broken-link-checker
blc https://username.github.io/repo/ -ro
```

### Test responsywności
```bash
# Używając przeglądarki:
# DevTools (F12) > Toggle device toolbar (Ctrl+Shift+M)
# Testuj: Mobile (375px), Tablet (768px), Desktop (1920px)
```

---

## Status testów

### Faza 1: ZAKOŃCZONA
- [x] Hugo zainstalowany
- [x] Struktura projektu
- [x] Serwer lokalny działa
- [x] Git zainicjalizowany

### Faza 2: ZAKOŃCZONA
- [x] GitHub repo
- [x] GitHub Actions
- [x] Deployment

### Faza 3: ZAKOŃCZONA
- [x] Decap CMS z focal-point i kompresją obrazków

### Faza 4: W TOKU
- [x] DecapBridge skonfigurowany, logowanie działa
- [ ] Dokumentacja zamiany providera
- [ ] Przetestowane 2+ providery

### Faza 5: W TOKU
- [x] Content & Design (artykuły, wydania, autorzy, magazynowy layout, focal point)
- [ ] Strategia strony głównej (najnowsze wydanie vs lista artykułów)

### Faza 6: W TOKU
- [x] Testy integralności (Go)
- [ ] BackstopJS w CI
- [ ] Multi-user test
- [ ] Dokumentacja redaktora
