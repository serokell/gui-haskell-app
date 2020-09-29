.PHONY: build dev clean

build:
	ghc ./Main.hs -outputdir _build -o gui-haskell-app -threaded -Wall -O2

dev:
	ghcid ./Main.hs

clean:
	rm -rf _build
