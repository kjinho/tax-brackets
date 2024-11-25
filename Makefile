ELM ?= elm 

main.js: src/Main.elm src/TaxData.elm
	$(ELM) make src/Main.elm --output=main.js

taxdata.js: src/TaxData.elm
	$(ELM) make src/TaxData.elm --output=taxdata.js

.PHONY: all
all: main.js taxdata.js index.html 

.PHONY: clean
clean: 
	rm -rf main.js taxdata.js