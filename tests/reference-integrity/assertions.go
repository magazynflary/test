package referenceintegrity

import (
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/PuerkitoBio/goquery"
)

const projectRoot = "../.."

func openDocument(t *testing.T, filename_in string) *goquery.Document {
	t.Helper()
	path := filepath.Join(projectRoot, filename_in)
	file, err := os.Open(path)
	if err != nil {
		t.Fatalf("cannot open %s: %v", path, err)
	}
	defer file.Close()
	doc, err := goquery.NewDocumentFromReader(file)
	if err != nil {
		t.Fatalf("cannot parse %s: %v", path, err)
	}
	return doc
}

func assertHasHTMLElement(t *testing.T, filename_in, selector string) {
	t.Helper()
	t.Log(filename_in)
	if openDocument(t, filename_in).Find(selector).Length() == 0 {
		t.Errorf("%s: element %q not found", filename_in, selector)
	}
}

func assertHasLink(t *testing.T, filename_in, href string) {
	t.Helper()
	if openDocument(t, filename_in).Find("a[href='"+href+"']").Length() == 0 {
		t.Errorf("%s: link to %q not found", filename_in, href)
	}
}

// assertSelectorLinksToValidFile fails if any element matching selector
// has an href that does not resolve to a file under public/.
func assertSelectorLinksToValidFile(t *testing.T, filename_in, selector string) {
	t.Helper()
	t.Log(filename_in)
	bp := siteBasePath(t)
	openDocument(t, filename_in).Find(selector).Each(func(_ int, s *goquery.Selection) {
		href, exists := s.Attr("href")
		if !exists {
			t.Errorf("%s: %q element has no href", filename_in, selector)
			return
		}
		u, err := url.Parse(href)
		if err != nil {
			t.Errorf("%s: invalid href %q: %v", filename_in, href, err)
			return
		}
		// u.Path is already percent-decoded; strip the site base path prefix.
		rel := strings.TrimPrefix(u.Path, bp)
		target := filepath.Join(projectRoot, "public", filepath.FromSlash(rel), "index.html")
		if _, err := os.Stat(target); err != nil {
			t.Errorf("%s: %q links to %q but %s does not exist", filename_in, selector, href, target)
		}
	})
}

// siteBasePath returns the URL path prefix from hugo.toml's baseURL (e.g. "/test").
func siteBasePath(t *testing.T) string {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(projectRoot, "hugo.toml"))
	if err != nil {
		t.Fatalf("cannot read hugo.toml: %v", err)
	}
	for _, line := range strings.Split(string(data), "\n") {
		if !strings.Contains(line, "baseURL") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		raw := strings.Trim(strings.TrimSpace(parts[1]), `'"`)
		u, err := url.Parse(raw)
		if err == nil {
			return strings.TrimSuffix(u.Path, "/")
		}
	}
	return ""
}
