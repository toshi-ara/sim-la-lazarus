all: test

build:
	lazbuild SimLATest.lpi

test: build
	./SimLATest -a --format=plain

clean:
	rm -rf SimLATest backup/ bin/ lib/

