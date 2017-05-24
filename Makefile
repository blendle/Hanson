# Use tabs instead of spaces for indentation

all: setup test 

setup:
	@./script/setup

test:
	@./script/test

# Targets that don't generate files of the same name
.PHONY: all setup test
