# Instrukcja Deploy na GitHub Pages

## Walidacja przed deploymentem

Przed rozpoczęciem upewnij się, że projekt jest gotowy:

```bash
make validate-ready
```

Powinieneś zobaczyć: `✓ Projekt gotowy do GitHub Pages!`

## Krok 1: Utwórz GitHub Repository

### Opcja A: Repo osobiste
1. Przejdź na https://github.com/new
2. Nazwa repo: dowolna (np. `medium-test`, `gazeta`, etc.)
3. **NIE** zaznaczaj "Initialize with README"
4. Kliknij "Create repository"

### Opcja B: Repo organizacji
1. Przejdź na https://github.com/organizations/TWOJA-ORG/repositories/new
2. Postępuj jak w opcji A

## Krok 2: Zaktualizuj baseURL

Edytuj `hugo.toml`:

```toml
# Dla repo osobistego:
baseURL = 'https://USERNAME.github.io/REPO/'

# Dla repo organizacji:
baseURL = 'https://ORG-NAME.github.io/REPO/'

# Dla custom domain (opcjonalnie):
baseURL = 'https://twoja-domena.pl/'
```

Przykład:
```toml
baseURL = 'https://jankowalski.github.io/gazeta/'
```

## Krok 3: Dodaj Remote i Push

```bash
# Dodaj remote (zastąp USERNAME i REPO)
git remote add origin https://github.com/USERNAME/REPO.git

# Sprawdź remote
git remote -v

# Push do GitHub
git push -u origin main
```

## Krok 4: Włącz GitHub Pages

1. Przejdź do swojego repo na GitHub
2. Kliknij **Settings** (zakładka na górze)
3. W lewym menu kliknij **Pages**
4. W sekcji "Build and deployment":
   - **Source**: wybierz "GitHub Actions"
5. Zapisz

## Krok 5: Zaczekaj na deployment

1. Przejdź do zakładki **Actions** w repo
2. Zobaczysz workflow "Deploy Hugo site to Pages"
3. Poczekaj aż skończy (zielony ✓)
4. Strona będzie dostępna pod: `https://USERNAME.github.io/REPO/`

Pierwszy deployment może zająć 2-5 minut.

## Testowanie przed pushem

### Test lokalny buildu produkcyjnego
```bash
make test-production
```

Symuluje dokładnie to, co wykona GitHub Actions.

### Test wszystkich komponentów
```bash
make test
```

## Troubleshooting

### Workflow nie startuje automatycznie
- Sprawdź czy plik `.github/workflows/deploy.yml` jest w repo
- Sprawdź zakładkę Actions - czy workflow jest widoczny

### 404 na stronie
- Sprawdź czy baseURL w `hugo.toml` jest poprawny
- Upewnij się że kończy się na `/`
- Zaczekaj kilka minut - może być opóźnienie

### CSS się nie ładuje
- Sprawdź baseURL - musi być poprawny
- Sprawdź czy `/css/style.css` i `/css/style-magazine.css` istnieją w wyniku
- Sprawdź DevTools > Network w przeglądarce

### Workflow fail
- Przejdź do Actions i kliknij na failed workflow
- Sprawdź logi
- Najczęstszy problem: błąd w hugo.toml lub brak plików

## Automatyczny deployment

Po pierwszym setupie każdy `git push` do brancha `main` automatycznie:
1. Triggeruje workflow
2. Builduje stronę
3. Deployuje na GitHub Pages

## Custom Domain (opcjonalnie)

Jeśli masz swoją domenę:

1. W Settings > Pages dodaj custom domain
2. Zaktualizuj baseURL w `hugo.toml`
3. Skonfiguruj DNS u swojego providera:
   - Typ: CNAME
   - Name: www (lub @)
   - Value: USERNAME.github.io

## Przydatne komendy

```bash
make validate-ready
make test-production
make test
```

## Limity GitHub Pages

- **Bandwidth**: 100GB/miesiąc
- **Build**: 10 builds/godzinę
- **Rozmiar repo**: 1GB (zalecane)
- **Rozmiar strony**: 1GB

## Następne kroki po deployment

Po udanym deploymencie możesz:
1. Dodać Decap CMS (Faza 3)
2. Skonfigurować uwierzytelnianie (Faza 4)
3. Dodać więcej treści (Faza 5)
4. Zaprosić redaktorów

