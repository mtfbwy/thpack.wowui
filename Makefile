.PHONY: all
all:
	@bash build/build.sh

.PHONY: install
install:
	@bash build/build.sh install

.PHONY: clean
clean:
	@echo "cleaning ..."
	@rm -rf ./out/*
