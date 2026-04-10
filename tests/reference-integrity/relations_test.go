package referenceintegrity

import (
	"path/filepath"
	"testing"
)

// Canary: always skipped. Confirms the test runner executes this package.
func TestCanary(t *testing.T) {
	t.Skip("Canary.")
}

// --- Home page ---

func TestHomePageHasArticles(t *testing.T) {
	assertHasHTMLElement(t, "public/index.html", ".post-card")
}

func TestHomePageArticleLinksAreValid(t *testing.T) {
	assertSelectorLinksToValidFile(t, "public/index.html", "a.post-card__link")
}

// --- Edition list ---

func TestEditionsPageHasEditions(t *testing.T) {
	assertHasHTMLElement(t, "public/wydania/index.html", ".post-card")
}

func TestEditionsPageLinksAreValid(t *testing.T) {
	assertSelectorLinksToValidFile(t, "public/wydania/index.html", "a.post-card__link")
}

// --- Single edition ---

func TestEditionHasFeaturedArticle(t *testing.T) {
	assertHasHTMLElement(t, "public/wydania/nieczytane-traktaty/index.html", ".post-card--featured")
}

func TestEditionArticleLinksAreValid(t *testing.T) {
	assertSelectorLinksToValidFile(t, "public/wydania/nieczytane-traktaty/index.html", "a.post-card__link")
}

// --- All editions ---

func TestAllEditionHasFeaturedArticle(t *testing.T) {
	for _, file := range editionFiles(t) {
		assertHasHTMLElement(t, file, ".post-card--featured")
	}
}

func TestAllEditionArticleLinksAreValid(t *testing.T) {
	for _, file := range editionFiles(t) {
		assertSelectorLinksToValidFile(t, file, "a.post-card__link")
	}
}

func editionFiles(t *testing.T) []string {
	t.Helper()
	pattern := filepath.Join(projectRoot, "public/wydania/*/index.html")
	abs, err := filepath.Glob(pattern)
	if err != nil || len(abs) == 0 {
		t.Fatal("no edition files found in public/ — run hugo build first")
	}
	rel := make([]string, len(abs))
	for i, f := range abs {
		rel[i], _ = filepath.Rel(projectRoot, f)
	}
	return rel
}

// --- All authors ---

func TestAllAuthorPagesHaveArticles(t *testing.T) {
	for _, file := range authorFiles(t) {
		assertHasHTMLElement(t, file, ".post-card")
	}
}

func TestAllAuthorArticleLinksAreValid(t *testing.T) {
	for _, file := range authorFiles(t) {
		assertSelectorLinksToValidFile(t, file, "a.post-card__link")
	}
}

func authorFiles(t *testing.T) []string {
	t.Helper()
	pattern := filepath.Join(projectRoot, "public/autorzy/*/index.html")
	abs, err := filepath.Glob(pattern)
	if err != nil || len(abs) == 0 {
		t.Fatal("no author files found in public/ — run hugo build first")
	}
	rel := make([]string, len(abs))
	for i, f := range abs {
		rel[i], _ = filepath.Rel(projectRoot, f)
	}
	return rel
}

// --- Single article ---

const testArticle = "public/2026/02/10/czy-poganin-może-mieć-prawa-pytamy-redakcję/index.html"

func TestArticleHasAuthorLink(t *testing.T) {
	assertHasHTMLElement(t, testArticle, "a.article-author-link")
}

func TestArticleAuthorLinkIsValid(t *testing.T) {
	assertSelectorLinksToValidFile(t, testArticle, "a.article-author-link")
}

func TestArticleHasEditionLink(t *testing.T) {
	assertHasHTMLElement(t, testArticle, "a.article-edition-link")
}

func TestArticleEditionLinkIsValid(t *testing.T) {
	assertSelectorLinksToValidFile(t, testArticle, "a.article-edition-link")
}

// --- All articles ---

func TestAllArticleAuthorLinks(t *testing.T) {
	for _, file := range articleFiles(t) {
		assertSelectorLinksToValidFile(t, file, "a.article-author-link")
	}
}

func TestAllArticleEditionLinks(t *testing.T) {
	for _, file := range articleFiles(t) {
		assertSelectorLinksToValidFile(t, file, "a.article-edition-link")
	}
}

func articleFiles(t *testing.T) []string {
	t.Helper()
	pattern := filepath.Join(projectRoot, "public/[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9]/*/index.html")
	abs, err := filepath.Glob(pattern)
	if err != nil || len(abs) == 0 {
		t.Fatal("no article files found in public/ — run hugo build first")
	}
	rel := make([]string, len(abs))
	for i, f := range abs {
		rel[i], _ = filepath.Rel(projectRoot, f)
	}
	return rel
}
