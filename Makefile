.PHONY: all
all:
	@bash build/build.sh

.PHONY: install
install:
	@bash build/install.sh

.PHONY: clean
clean:
	@echo "cleaning ..."
	@rm -rf ./out/*
