#!/bin/bash

# Automatyczne testy - Decap CMS Setup

set -e

FAILED=0
PASSED=0

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "TESTY: Decap CMS Setup"
echo "========================================="
echo ""

# Funkcja testowa
test_assert() {
    local name="$1"
    local command="$2"

    echo -n "Test: $name... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# Test 1: Pliki CMS istnieją
test_assert "Admin index.html istnieje" "[ -f static/admin/index.html ]"
test_assert "Admin config.yml istnieje" "[ -f static/config.yml ]"

# Test 2: Zawartość index.html
test_assert "index.html zawiera Decap CMS" "grep -q 'decap-cms' static/admin/index.html"

# Test 3: Konfiguracja config.yml
test_assert "config.yml zawiera backend" "grep -q 'backend:' static/config.yml"
test_assert "config.yml zawiera collections" "grep -q 'collections:' static/config.yml"
test_assert "config.yml zawiera publish_mode" "grep -q 'publish_mode:' static/config.yml"

# Test 4: Kolekcje
test_assert "Kolekcja 'posts' istnieje" "grep -q 'name: \"posts\"' static/config.yml"
test_assert "Kolekcja 'pages' istnieje" "grep -q 'name: \"pages\"' static/config.yml"
test_assert "Kolekcja 'authors' istnieje" "grep -q 'name: \"authors\"' static/config.yml"
test_assert "Kolekcja 'editions' istnieje" "grep -q 'name: \"editions\"' static/config.yml"
test_assert "Kolekcja 'editions' wskazuje na content/wydania" "grep -q 'folder: \"content/wydania\"' static/config.yml"
test_assert "_index.md nie jest widoczny w CMS (brak editions w config)" "! grep -q 'content/editions' static/config.yml"

# Test 5: Media folder
test_assert "media_folder skonfigurowany" "grep -q 'media_folder:' static/config.yml"
test_assert "Katalog uploads istnieje" "[ -d assets/images/uploads ]"

# Test 6: Struktury katalogów
test_assert "Katalog content/authors istnieje" "[ -d content/authors ]"
test_assert "Katalog content/pages istnieje" "[ -d content/pages ]"

# Test 7: Przykładowa zawartość
test_assert "Przykładowy autor istnieje" "[ -f content/authors/redaktor-testowy.md ]"
test_assert "Strona About istnieje" "[ -f content/pages/about.md ]"

# Test 8: YAML syntax validation (podstawowa)
echo -n "Test: config.yml poprawny YAML... "
if python3 -c "import yaml" 2>/dev/null; then
    if python3 -c "import yaml; yaml.safe_load(open('static/config.yml'))" 2>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}SKIP (PyYAML not installed)${NC}"
fi

# Test 9: Build z CMS działa
echo -n "Test: Hugo build z CMS... "
if hugo --quiet --minify --buildFuture 2>&1 | grep -q "Error"; then
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
else
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
fi

# Test 10: Panel admin dostępny po buildzie
test_assert "public/admin/index.html wygenerowany" "[ -f public/admin/index.html ]"
test_assert "public/admin/config.yml wygenerowany" "[ -f public/admin/config.yml ]"

# Podsumowanie
echo ""
echo "========================================="
echo "PODSUMOWANIE"
echo "========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Decap CMS poprawnie skonfigurowany!${NC}"
    echo ""
    echo "Następne kroki:"
    echo "1. Uruchom lokalnie: make hugo-cms"
    echo "2. Otwórz: http://localhost:1313/admin/"
    echo "3. Wybierz 'Work with Local Repository' (test mode)"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Niektóre testy nie przeszły.${NC}"
    exit 1
fi
