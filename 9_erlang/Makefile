.PHONY: run

ERLC=erlc
ERLCFLAGS=-o build
SOURCES=$(wildcard src/*.erl)

run: compile
	erl -pa build -noshell -s main start -s init stop

debug: compile
	erl -pa build

compile:
	mkdir -p build
	$(ERLC) $(ERLCFLAGS) $(SOURCES)

clean:
	rm -f build/*.beam

setup_ci:
	apt install --no-install-recommends -y erlang
