all: draft-hanson-oauth-resource-token-resp.xml draft-hanson-oauth-resource-token-resp.txt

%.xml: %.md
	kramdown-rfc $< >$@

%.txt: %.xml
	xml2rfc $< -o $@ --text

%.html: %.xml
	xml2rfc $< -o $@ --html
