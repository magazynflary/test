#!/bin/bash

# Automatyczne testy - Faza 1: Inicjalizacja projektu
# Data: 2026-02-07

set -e

FAILED=0
PASSED=0

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "TESTY FAZY 1: Inicjalizacja projektu"
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

# Test 1.1: Hugo zainstalowany i działający
test_assert "Hugo zainstalowany" "command -v hugo"
test_assert "Hugo wersja >= 0.100" "hugo version | grep -E 'v0\.(1[5-9][0-9]|[2-9][0-9]{2})'"

# Test 1.2: Struktura projektu utworzona
test_assert "Katalog archetypes/ istnieje" "[ -d archetypes ]"
test_assert "Katalog content/ istnieje" "[ -d content ]"
test_assert "Katalog layouts/ istnieje" "[ -d layouts ]"
test_assert "Katalog static/ istnieje" "[ -d static ]"
test_assert "Plik hugo.toml istnieje" "[ -f hugo.toml ]"
test_assert "Plik .gitignore istnieje" "[ -f .gitignore ]"

# Test 1.3: Konfiguracja Hugo poprawna
test_assert "hugo.toml zawiera title" "grep -q 'title' hugo.toml"
test_assert "hugo.toml zawiera baseURL" "grep -q 'baseURL' hugo.toml"
test_assert "hugo.toml zawiera languageCode" "grep -q 'languageCode' hugo.toml"

# Test 1.4: Layouts utworzone
test_assert "Layout baseof.html istnieje" "[ -f layouts/_default/baseof.html ]"
test_assert "Layout list.html istnieje" "[ -f layouts/_default/list.html ]"
test_assert "Layout single.html istnieje" "[ -f layouts/_default/single.html ]"
test_assert "Layout index.html istnieje" "[ -f layouts/index.html ]"

# Test 1.5: CSS
test_assert "CSS style.css istnieje" "[ -f static/css/style.css ]"
test_assert "baseof.html linkuje CSS" "grep -q 'style.css' layouts/_default/baseof.html"

# Test 1.6: Przykładowa treść
test_assert "Katalog content/artykuly/ istnieje" "[ -d content/artykuly ]"
test_assert "Przykładowy post istnieje" "[ -f content/artykuly/pierwszy-post.md ]"

# Test 1.7: Git zainicjalizowany
test_assert "Git repo zainicjalizowane" "[ -d .git ]"
test_assert "Istnieje co najmniej 1 commit" "[ $(git rev-list --count HEAD) -ge 1 ]"
test_assert ".gitignore zawiera public/" "grep -q 'public/' .gitignore"

# Test 1.8: Hugo build działa
echo -n "Test: Hugo build bez błędów... "
if hugo --quiet 2>&1 | grep -q "Error"; then
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
else
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
fi

# Test 1.9: Katalog public/ został utworzony
test_assert "Build stworzył katalog public/" "[ -d public ]"
test_assert "public/index.html istnieje" "[ -f public/index.html ]"
test_assert "public/css/style.css istnieje" "[ -f public/css/style.css ]"

# Podsumowanie
echo ""
echo "========================================="
echo "PODSUMOWANIE"
echo "========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Wszystkie testy przeszły pomyślnie!${NC}"
    exit 0
else
    echo -e "${RED}✗ Niektóre testy nie przeszły.${NC}"
    exit 1
fi
