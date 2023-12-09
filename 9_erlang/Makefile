.PHONY: run

ERLC=erlc
ERLCFLAGS=-o build
SOURCES=$(wildcard src/*.erl)

run: compile
	erl -pa build -noshell -s main start -s init stop

debug: compile
	erl -pa build

compile:
	$(ERLC) $(ERLCFLAGS) $(SOURCES)

clean:
	rm -f build/*.beam

