#!/bin/bash

# Automatyczne testy - Serwer lokalny Hugo
# Test treści strony na localhost:$PORT

set -e

FAILED=0
PASSED=0
SERVER_PID=""
PORT=1313

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "TESTY: Lokalny serwer Hugo"
echo "========================================="
echo ""

# Funkcja cleanup
cleanup() {
    if [ ! -z "$SERVER_PID" ]; then
        echo ""
        echo "Zatrzymuję serwer Hugo (PID: $SERVER_PID)..."
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

# Funkcja testowa HTTP
test_http() {
    local name="$1"
    local url="$2"
    local expected="$3"

    echo -n "Test: $name... "

    local response=$(curl -s "$url" 2>/dev/null)

    if echo "$response" | grep -q "$expected"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Oczekiwano: $expected"
        ((FAILED++))
        return 1
    fi
}

# Funkcja testowa status HTTP
test_http_status() {
    local name="$1"
    local url="$2"
    local expected_status="$3"

    echo -n "Test: $name... "

    local status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)

    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Oczekiwano: $expected_status, otrzymano: $status"
        ((FAILED++))
        return 1
    fi
}

# Uruchom serwer Hugo w tle
echo "Uruchamianie serwera Hugo..."
hugo server --buildDrafts --baseURL "http://localhost:$PORT/" > /tmp/hugo-test-server.log 2>&1 &
SERVER_PID=$!

echo "Serwer Hugo uruchomiony (PID: $SERVER_PID)"
echo "Czekam na uruchomienie serwera..."

# Czekaj aż serwer się uruchomi
for i in {1..30}; do
    if curl -s http://localhost:$PORT/ > /dev/null 2>&1; then
        echo -e "${GREEN}Serwer gotowy!${NC}"
        echo ""
        break
    fi
    sleep 0.5
done

# Sprawdź czy serwer działa
if ! curl -s http://localhost:$PORT/ > /dev/null 2>&1; then
    echo -e "${RED}BŁĄD: Serwer nie uruchomił się poprawnie${NC}"
    cat /tmp/hugo-test-server.log
    exit 1
fi

# Test 1: Strona główna
test_http_status "Strona główna zwraca 200" "http://localhost:$PORT/" "200"
test_http "Strona główna zawiera tytuł" "http://localhost:$PORT/" "Flary"
test_http "Strona główna zawiera Najnowsze" "http://localhost:$PORT/" "Najnowsze"

# Test 2: CSS
test_http_status "CSS dostępny" "http://localhost:$PORT/css/style.css" "200"
test_http "CSS zawiera font-family" "http://localhost:$PORT/css/style.css" "font-family"
test_http "CSS zawiera max-width" "http://localhost:$PORT/css/style.css" "max-width"

# Test 3: Strona z postami
test_http_status "Lista postów zwraca 200" "http://localhost:$PORT/artykuly/" "200"
test_http "Lista postów zawiera Artykuły" "http://localhost:$PORT/artykuly/" "Artykuły"

# Test 4: Przykładowy post
test_http_status "Artykuł zwraca 200" "http://localhost:$PORT/2026/03/20/reforma-czy-rewolucja-z-przypisami-redakcji/" "200"
test_http "Artykuł zawiera tytuł" "http://localhost:$PORT/2026/03/20/reforma-czy-rewolucja-z-przypisami-redakcji/" "Reforma"
test_http "Artykuł zawiera treść" "http://localhost:$PORT/2026/03/20/reforma-czy-rewolucja-z-przypisami-redakcji/" "article-content"

# Test 5: Lista wydań
test_http_status "Lista wydań zwraca 200" "http://localhost:$PORT/wydania/" "200"
test_http "Lista wydań zawiera nagłówek" "http://localhost:$PORT/wydania/" "Wydania"
test_http "Lista wydań zawiera siatkę" "http://localhost:$PORT/wydania/" "posts-grid"
test_http "Lista wydań zawiera kartę wydania" "http://localhost:$PORT/wydania/" "post-card"

# Test 6: Pojedyncze wydanie
test_http_status "Wydanie zwraca 200" "http://localhost:$PORT/wydania/nieczytane-traktaty/" "200"
test_http "Wydanie zawiera tytuł" "http://localhost:$PORT/wydania/nieczytane-traktaty/" "Nieczytane traktaty"
test_http "Wydanie zawiera artykuł główny" "http://localhost:$PORT/wydania/nieczytane-traktaty/" "post-card--featured"

# Test 7: HTML structure (strona główna)
test_http "Strona ma DOCTYPE" "http://localhost:$PORT/" "<!DOCTYPE html>"
test_http "Strona ma charset UTF-8" "http://localhost:$PORT/" "UTF-8"
test_http "Strona ma viewport" "http://localhost:$PORT/" "viewport"
test_http "Strona ma link do CSS" "http://localhost:$PORT/" "/css/style.css"

# Test 8: Nawigacja
test_http "Nawigacja zawiera link Start" "http://localhost:$PORT/" "href=\"http://localhost:$PORT/\""
test_http "Nawigacja zawiera tekst Start w nav" "http://localhost:$PORT/" "<span>Start</span>"
test_http "Nawigacja zawiera link Artykuły" "http://localhost:$PORT/" 'href="/artykuly/"'
test_http "Nawigacja zawiera tekst Artykuły w nav" "http://localhost:$PORT/" '<span>Artykuły</span>'

# Test 9: Content type headers
echo -n "Test: HTML ma prawidłowy Content-Type... "
content_type=$(curl -s -I http://localhost:$PORT/ | grep -i "content-type" | grep -i "text/html")
if [ ! -z "$content_type" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

echo -n "Test: CSS ma prawidłowy Content-Type... "
css_content_type=$(curl -s -I http://localhost:$PORT/css/style.css | grep -i "content-type" | grep -i "text/css")
if [ ! -z "$css_content_type" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

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
    echo ""
    echo "Logi serwera:"
    cat /tmp/hugo-test-server.log
    exit 1
fi
