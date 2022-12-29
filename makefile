## ----------------------------------------------------------------------
## VERSION v1.0
## AUTHOR  Phu Quang
## ----------------------------------------------------------------------
SCRIPT_VERSION=v1.0
SCRIPT_AUTHOR=Phu Quang

# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall

.DEFAULT_GOAL := help

ifndef APP_ENV
	ifneq ("$(wildcard .env)","")
		include .env
	endif
endif

proxy_user=-u $(DOCKER_USER)

COMPOSE=docker compose
BUILD=up -d --build
DOWN=rm -fsv

all:
	@echo  ''

help:
	@echo
	@echo "Available command:"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@:

up:                                ## docker-compose up
	$(COMPOSE) up -d

down:                              ## docker-compose down
	$(COMPOSE) down

ps:                                ## docker-compose ps
	$(COMPOSE) ps

build:                             ## Build with service name (ex: make build s=proxy)
	@echo Building to service $(s)...
	@$(COMPOSE) $(BUILD) $(s)
	@$(COMPOSE) logs $(s)

proxy-restart:                     ## docker exec workspace_proxy service nginx restart
	@$(COMPOSE) exec proxy service nginx restart

proxy-reload:                      ## docker proxy reload
	@$(COMPOSE) exec proxy service nginx reload
	@$(COMPOSE) exec apache service apache2 reload

sh:                                ## SH with service name (ex: make sh s=proxy)
	@echo Connecting to service $(s)...
	@$(COMPOSE) exec -it $(s) bash

log:                               ## docker run log
	@$(COMPOSE) logs $(s)

run-wrk:                           ## docker run wrk
	@docker run --rm -it $(APP_CONTAINER_NAME)_wrk:wrk wrk2 --version

list:                              ## docker list all
	@echo "All container:"
	@docker ps -a -s --format "table {{.ID}}\\t{{.Image}}\\t{{.Status}}\\t{{.Names}}\\t{{.Size}}"
	@echo "Container running:"
	@docker ps -s --format "table {{.ID}}\\t{{.Image}}\\t{{.Status}}\\t{{.Names}}\\t{{.Size}}"
	@echo
	@echo "All images:"
	@docker images --format "table {{.ID}}\\t{{.Repository}}\\t{{.Tag}}\\t{{.Size}}"
	@echo
	@echo "All networks:"
	@docker network ls

# remove-mysql:
# 	docker compose stop mysql && docker compose rm mysql -f
# 	docker rmi $(docker images -q mysql)
# 	docker volume rm workspace_data-mysql

clean:
	@:

_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

.PHONY: all help build clean
