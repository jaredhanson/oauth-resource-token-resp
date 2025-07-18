all: draft-hanson-oauth-resource-token-resp.xml draft-hanson-oauth-resource-token-resp.txt draft-hanson-oauth-resource-token-resp.html

%.xml: %.md
	kramdown-rfc $< >$@

%.txt: %.xml
	xml2rfc $< -o $@ --text

%.html: %.xml
	xml2rfc $< -o $@ --html
