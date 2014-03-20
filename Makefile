ISSO_JS_SRC := $(shell find isso/js/app -type f) $(shell ls isso/js/*.js | grep -vE "(min|dev)")
ISSO_JS_DST := isso/js/embed.min.js isso/js/embed.dev.js isso/js/count.min.js isso/js/count.dev.js

ISSO_CSS_DST := isso/css/isso.css
ISSO_CSS_SRC := isso/css/isso.scss
ISSO_CSS_SRC_DEPS := $(shell find isso/css -type f | grep .scss)

RST := $(shell find docs/ -type f -name  '*.rst')
MAN := man/man1/isso.1 man/man5/isso.conf.5

WWW := docs/index.html docs/isso.example.cfg $(wildcard docs/_static/*)
CSS := docs/_static/css/site.css

all: man js site

init:
	(cd isso/js; bower install almond requirejs requirejs-text)

${ISSO_CSS_DST}: $(ISSO_CSS_SRC_DEPS)
	scss --no-cache $(ISSO_CSS_SRC) $@

isso/js/%.min.js: $(ISSO_JS_SRC) $(ISSO_CSS_DST)
	r.js -o isso/js/build.$*.js out=$@

isso/js/%.dev.js: $(ISSO_JS_SRC) $(ISSO_CSS_DST)
	r.js -o isso/js/build.$*.js optimize="none" out=$@

js: $(ISSO_JS_DST)
css: $(ISSO_CSS_DST)

man: $(RST)
	sphinx-build -b man docs/ man/

${CSS}: docs/_static/css/site.scss
	scss --no-cache $< $@

site: $(RST) $(WWW) $(CSS)
	cd docs && sphinx-build -b dirhtml . _build/html

coverage:
	nosetests --with-doctest --with-doctest-ignore-unicode --with-coverage \
	          --cover-package=isso --cover-html isso/ specs/

clean:
	rm -f $(MAN) $(CSS) $(ISSO_JS_DST) $(ISSO_CSS_DST)

.PHONY: clean site man init js css

