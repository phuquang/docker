## ----------------------------------------------------------------------
## VERSION v1.0
## AUTHOR  Phu Quang
## ----------------------------------------------------------------------
# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall

.DEFAULT_GOAL := help

proxy_user=-u $(DOCKER_USER)

COMPOSE=docker-compose
BUILD=up -d --build
DOWN=rm -fsv

help:
	@:

up:
	$(COMPOSE) -f $(COMPOSE).test.yml up -d

down:
	$(COMPOSE) -f $(COMPOSE).test.yml down

build:
	$(COMPOSE) -f $(COMPOSE).test.yml $(BUILD) $(s)

sh:
	$(COMPOSE) -f $(COMPOSE).test.yml exec -it $(s) bash

log:
	$(COMPOSE) logs $(s)

pauli:
	ifndef TEST
		@echo $(TEST)
	endif

_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

.PHONY: help
