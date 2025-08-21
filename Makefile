OUTDIR ?= _site

all: $(OUTDIR) draft-hanson-oauth-resource-token-resp.xml draft-hanson-oauth-resource-token-resp.txt draft-hanson-oauth-resource-token-resp.html

$(OUTDIR):
	git worktree add -B gh-pages $@ origin/gh-pages

%.xml: %.md
	kramdown-rfc $< >$@

%.txt: %.xml
	xml2rfc $< -o $@ --text

%.html: %.xml
	xml2rfc $< -o $@ --html
