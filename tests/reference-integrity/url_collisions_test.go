package referenceintegrity

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// Reserved top-level paths. Article `url:` must not start with these — collision
// with Hugo section/asset output would silently overwrite files.
// Keep in sync with the `pattern` regex on the `url` field in static/config.yml.
var reservedTopLevelPaths = []string{
	"artykuly", "autorzy", "pages", "tags", "wydania",
	"admin", "css", "images",
}

var frontMatterURLPattern = regexp.MustCompile(`(?m)^url:\s*["']?(\S+?)["']?\s*$`)

func extractFrontMatterURL(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("cannot read %s: %v", path, err)
	}
	text := string(data)
	if !strings.HasPrefix(text, "---") {
		return ""
	}
	end := strings.Index(text[3:], "---")
	if end < 0 {
		return ""
	}
	match := frontMatterURLPattern.FindStringSubmatch(text[3 : 3+end])
	if match == nil {
		return ""
	}
	return match[1]
}

func articleSourceFiles(t *testing.T) []string {
	t.Helper()
	pattern := filepath.Join(projectRoot, "content/artykuly/*.md")
	matches, err := filepath.Glob(pattern)
	if err != nil || len(matches) == 0 {
		t.Fatal("no article sources found in content/artykuly/")
	}
	return matches
}

// TestNoDuplicateArticleURLs fails if two articles declare the same `url:`.
// Hugo would silently overwrite the first build with the second.
func TestNoDuplicateArticleURLs(t *testing.T) {
	owners := map[string][]string{}
	for _, file := range articleSourceFiles(t) {
		customURL := extractFrontMatterURL(t, file)
		if customURL == "" {
			continue
		}
		owners[customURL] = append(owners[customURL], filepath.Base(file))
	}
	for customURL, files := range owners {
		if len(files) > 1 {
			t.Errorf("url %q declared by %d articles: %v", customURL, len(files), files)
		}
	}
}

// TestNoArticleURLCollidesWithReservedSection fails if an article's `url:`
// starts with a top-level path used by Hugo sections or static assets.
func TestNoArticleURLCollidesWithReservedSection(t *testing.T) {
	for _, file := range articleSourceFiles(t) {
		customURL := extractFrontMatterURL(t, file)
		if customURL == "" {
			continue
		}
		firstSegment := strings.SplitN(strings.Trim(customURL, "/"), "/", 2)[0]
		for _, reserved := range reservedTopLevelPaths {
			if firstSegment == reserved {
				t.Errorf("%s: url %q collides with reserved section /%s/", filepath.Base(file), customURL, reserved)
			}
		}
	}
}
