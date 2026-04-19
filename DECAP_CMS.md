# Decap CMS - Instrukcja użytkowania

## Czym jest Decap CMS?

Decap CMS (dawniej Netlify CMS) to open-source'owy system zarządzania treścią dla stron statycznych. Działa bezpośrednio z plikami w repozytorium Git.

## Pliki CMS

| Plik | Rola |
|------|------|
| `static/admin/index.html` | Interfejs Decap CMS + logika JS (kadr obrazka, kompresja) |
| `static/config.yml` | Konfiguracja: backend, kolekcje, pola |
| `assets/images/uploads/` | Nadesłane obrazki |

Widgety i pola: `static/admin/index.html`. Kolekcje i backend: `static/config.yml`.

## Tryby pracy

### 1. Tryb lokalny (testowy)
Do testowania bez GitHuba.

**Użycie:**
1. `make hugo-cms`
2. Otwórz http://localhost:1313/admin/
3. Kliknij "Work with Local Repository"
4. Edytuj treści (zapisują się lokalnie)

### 2. Tryb produkcyjny (GitHub)
Wymaga połączenia z GitHubem.

## Editorial Workflow

Decap CMS używa **editorial workflow** dla procesu redakcyjnego:

### Stany artykułu:
1. **Draft** - szkic, prywatny
2. **In Review** - oczekuje na recenzję
3. **Ready** - gotowy do publikacji

### Proces:
```
Draft → In Review → Ready → Publish
  ↓         ↓         ↓        ↓
(PR)    (update)  (approve) (merge)
```

### W praktyce (GitHub):
- **Draft** = nowy branch + PR
- **In Review** = PR czeka na review
- **Publish** = merge PR do main

## Media (obrazki)

**Lokalizacja:** `assets/images/uploads/`
**URL publiczny:** `/images/uploads/nazwa-pliku.jpg`

**Kompresja:** automatyczna, max 0.5 MB / 2000 px (biblioteka browser-image-compression, przechwycenie `<input type="file">` przed obróbką przez Decap CMS)

## Dostęp dla redaktorów

### Lokalnie (test):
- Każdy z dostępem do repo
- `make hugo-cms` → http://localhost:1313/admin/

### Produkcja (GitHub):
1. Redaktor loguje się przez GitHub
2. Musi mieć uprawnienia write w repo
3. Otwiera https://dlrzin.github.io/admin/
4. Tworzy/edytuje artykuły

## Zarządzanie redaktorami

### Dodanie nowego redaktora:
1. Zaproś do GitHub repo (Settings > Collaborators)
2. Nadaj uprawnienia "Write" lub "Maintain"
3. Redaktor może od razu logować się do CMS

### Role:
- **Read** - tylko podgląd (nie może edytować)
- **Write** - tworzenie i edycja (typowy redaktor)
- **Maintain** - + zarządzanie PR
- **Admin** - pełna kontrola

## Uwierzytelnianie

### Opcje (wybierz jedną):

#### 1. GitHub OAuth (zalecane dla małych zespołów)
- Bezpośrednie logowanie przez GitHub
- Darmowe
- **Wymaga:** GitHub OAuth App

#### 2. DecapBridge (proste dla większych zespołów)
- Serwer proxy dla OAuth
- Darmowy tier
- **Wymaga:** konfiguracja DecapBridge

### Zmiana providera uwierzytelniania

Wystarczy edytować `static/config.yml`:

```yaml
# GitHub OAuth
backend:
  name: github
  repo: user/repo
  branch: main

# DecapBridge
backend:
  name: github
  repo: user/repo
  branch: main
  base_url: https://your-decapbridge-url.com
  auth_endpoint: auth
```

## Testowanie CMS

### Test lokalny (bez GitHuba):
```bash
make test-cms        # Walidacja static/config.yml.
make hugo-cms        # Uruchamia serwer z lokalnym proxy CMS.
```

Otwórz: http://localhost:1313/admin/

### Test produkcyjny:
Po push do GitHub otwórz: https://dlrzin.github.io/admin/

## Troubleshooting

### Panel /admin/ nie ładuje się
- Sprawdź czy `static/admin/index.html` istnieje
- Sprawdź DevTools Console na błędy
- Sprawdź czy CDN Decap CMS jest dostępny

### "Error loading config.yml"
- Sprawdź składnię YAML: `make test-cms` (waliduje `static/config.yml`)
- Sprawdź czy backend repo jest poprawny
- Sprawdź wcięcia (YAML wymaga spacji, nie tabów)

### Nie mogę się zalogować
- Sprawdź uprawnienia w GitHub repo
- Sprawdź czy OAuth App jest skonfigurowana
- Sprawdź czy backend w config.yml jest poprawny

### Zmiany nie publikują się
- Sprawdź czy PR został zmergowany
- Sprawdź GitHub Actions - czy build się udał
- Może być opóźnienie 1-2 minuty

### Media nie wgrywają się
- Sprawdź czy katalog `assets/images/uploads/` istnieje
- Sprawdź uprawnienia zapisu
- Sprawdź rozmiar pliku — kompresja (max ~0.5 MB) działa automatycznie w przeglądarce

## Konfiguracja zaawansowana

### Dodanie nowej kolekcji

W `static/config.yml` dodaj:

```yaml
collections:
  - name: "nazwa"
    label: "Nazwa wyświetlana"
    folder: "content/nazwa"
    create: true
    fields:
      - {label: "Tytuł", name: "title", widget: "string"}
      - {label: "Treść", name: "body", widget: "markdown"}
```

### Pola kadrowania

Każdy obraz może mieć dwa niezależne kadry (baner vs karta):

```yaml
- label: "Focal point (baner)"
  name: "image_focus_banner"
  widget: "focal-point"  # Własny widget zarejestrowany w static/admin/index.html.
- label: "Focal point (karta)"
  name: "image_focus_card"
  widget: "focal-point"  # Jak wyżej.
```

Partial `focal-vars.html` przelicza wartości na zmienne CSS `--focal-pos` i `--focal-zoom`.

### Dostosowanie widgetów

Dostępne widgety:
- `string` - tekst krótki
- `text` - tekst wieloliniowy
- `markdown` - edytor Markdown
- `number` - liczba
- `boolean` - checkbox
- `datetime` - data i czas
- `image` - upload obrazka
- `file` - upload pliku
- `select` - lista wyboru
- `list` - lista elementów
- `object` - obiekt zagnieżdżony
- `relation` - powiązanie z inną kolekcją

### Walidacja pól

```yaml
fields:
  - label: "Email"
    name: "email"
    widget: "string"
    pattern: ['^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$', "Podaj poprawny email"]  # Notabene to kiepska walidacja
    required: true
```

## Limity

### GitHub:
- Max rozmiar pliku: 100MB
- Max rozmiar repo: 1GB (zalecane)
- Optimalizuj obrazki przed uploadem

### Decap CMS:
- Brak limitów (open-source)
- Wydajność zależy od rozmiaru repo

## Bezpieczeństwo

### Dobre praktyki:
1. **Nie commituj sekretów** - nigdy nie wrzucaj API keys do repo
2. **Uprawnienia minimalne** - dawaj tylko potrzebne uprawnienia
3. **Review PR** - zawsze review przed mergem
4. **Backupy** - Git to już backup, ale można też klonować repo

### Co Decap CMS NIE robi:
- Nie przechowuje haseł (używa GitHub)
- Nie ma dostępu do Twojego repo (działa w przeglądarce)
- Nie wysyła danych na zewnętrzne serwery

## Przydatne linki

- Dokumentacja Decap CMS: https://decapcms.org/docs/
- Widgety: https://decapcms.org/docs/widgets/
- Przykłady: https://decapcms.org/docs/examples/
- GitHub repo: https://github.com/decaporg/decap-cms
