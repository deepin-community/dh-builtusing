# -- Driven by debian/rules

all: obj/dh_builtusing.1

obj/%.1: %.pod | obj
	pod2man --utf8 -cDebhelper -r`dpkg-parsechangelog -SVersion` $< $@

obj:
	mkdir $@

check:
	sh run-unit-tests

clean:
	rm -fr obj/
	find . -name '*~' -a -type f -delete

# -- Useful during development

dev: c-dh_builtusing obj/tidy-dh_builtusing obj/critic-dh_builtusing \
     check \
     all \
     c-builtusing.pm obj/tidy-builtusing.pm obj/critic-builtusing.pm

c-%:
	perl -c $*

# apt install perltidy:
obj/tidy-%: %
	perltidy $< -st | diff -u $< -

no_critic = Modules::RequireVersionVar
obj/critic-builtusing.pm: no_critic += Modules::RequireExplicitPackage

# apt install libperl-critic-perl:
obj/critic-%: % Makefile | obj
	perlcritic -1 --verbose=11 $(no_critic:%=--exclude=%) $<
	touch $@
