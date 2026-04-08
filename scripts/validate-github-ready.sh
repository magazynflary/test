#!/bin/bash

# Walidacja czy projekt jest gotowy do GitHub Pages deployment

set -e

FAILED=0
PASSED=0

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "WALIDACJA: Gotowość do GitHub Pages"
echo "========================================="
echo ""

check() {
    local name="$1"
    local condition="$2"

    echo -n "Sprawdzam: $name... "

    if eval "$condition" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
        return 1
    fi
}

# Sprawdzenia
check "Git repo zainicjalizowane" "[ -d .git ]"
check "Są commity" "[ \$(git rev-list --count HEAD) -ge 1 ]"
check "Workflow GitHub Actions istnieje" "[ -f .github/workflows/deploy.yml ]"
check "Hugo config istnieje" "[ -f hugo.toml ]"
check "Layouts istnieją" "[ -d layouts ]"
check "Content istnieje" "[ -d content ]"
check ".gitignore zawiera public/" "grep -q 'public/' .gitignore"
check "Hugo build działa" "hugo --quiet --minify --buildFuture"

echo ""
echo "========================================="
echo "Pliki wymagane przez GitHub:"
echo "========================================="

FILES=(
    ".github/workflows/deploy.yml"
    "hugo.toml"
    "layouts/_default/baseof.html"
    "content/artykuly/pierwszy-post.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file"
        ((FAILED++))
    fi
done

echo ""
echo "========================================="
echo "PODSUMOWANIE"
echo "========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✓ Projekt gotowy do GitHub Pages!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "Następne kroki:"
    echo "1. Utwórz repo na GitHub"
    echo "2. git remote add origin https://github.com/USERNAME/REPO.git"
    echo "3. Zaktualizuj baseURL w hugo.toml"
    echo "4. git push -u origin main"
    echo "5. Włącz GitHub Pages w Settings > Pages"
    echo "   - Source: GitHub Actions"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Projekt NIE jest gotowy${NC}"
    echo "Popraw błędy i uruchom ponownie."
    exit 1
fi
