ELM ?= elm 
UGLIFY ?= uglifyjs
UGLIFY_P1_FLAGS=--compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe'
UGLIFY_P2_FLAGS=--mangle

main.js: src/Main.elm src/TaxData.elm
	$(ELM) make src/Main.elm --output=main.js

taxdata.js: src/TaxData.elm
	$(ELM) make src/TaxData.elm --output=taxdata.js

.PHONY: all
all: main.js taxdata.js index.html 

main.min.js: src/Main.elm src/TaxData.elm
	$(ELM) make src/Main.elm --optimize --output=main.js
	$(UGLIFY) main.js $(UGLIFY_P1_FLAGS) | $(UGLIFY) $(UGLIFY_P2_FLAGS) --output main.min.js

taxdata.min.js: src/TaxData.elm
	$(ELM) make src/TaxData.elm --optimize --output=taxdata.js
	$(UGLIFY) taxdata.js $(UGLIFY_P1_FLAGS) | $(UGLIFY) $(UGLIFY_P2_FLAGS) --output taxdata.min.js

index.deploy.html: index.html
	sed -e 's/"\(main\|taxdata\)[.]js"/"\1.min.js"/g' index.html > index.deploy.html

.PHONY: optimized
optimized: main.min.js taxdata.min.js index.deploy.html

.PHONY: deploy
deploy: optimized 
	mkdir output 
	cp main.min.js output/
	cp taxdata.min.js output/ 
	cp index.deploy.html output/index.html
	
.PHONY: clean
clean: 
	rm -rf main.js main.min.js taxdata.js taxdata.min.js index.deploy.html output