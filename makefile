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
	# Determine if .env file exist
	ifneq ("$(wildcard .env)","")
		include .env
	endif
endif

proxy_user=-u $(DOCKER_USER)

COMPOSE=docker compose
BUILD=up -d --build
DOWN=rm -fsv

all:
	$(info I renewed myself)
	@:

help:
	@echo
	@echo "Available command:"
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'
	@echo
	@:

up: ## docker-compose up
	@$(COMPOSE) up -d

down: ## docker-compose down
ifeq "$(s)" "proxy"
	$(COMPOSE) $(DOWN) proxy
else ifeq "$(s)" "apache"
	$(COMPOSE) $(DOWN) apache
else ifeq "$(s)" "php"
	$(COMPOSE) $(DOWN) php
else ifeq "$(s)" "ungit"
	$(COMPOSE) $(DOWN) ungit
else ifeq "$(s)" "supervisor"
	$(COMPOSE) $(DOWN) supervisor
else
	$(COMPOSE) down
endif
	@:

build: ## Build with service name (ex: make build s=proxy)
	@echo Building to service $(s)...
	@$(COMPOSE) $(BUILD) $(s)

sh: ## Connecting with service name (ex: make sh s=proxy)
	@echo Connecting to service $(s)...
ifeq "$(s)" "mysql"
	@$(COMPOSE) exec -it -u root:root mysql bash
else ifeq "$(s)" "ungit"
	@$(COMPOSE) exec -it -u root:root ungit bash
else ifeq "$(s)" "adminer"
	@$(COMPOSE) exec -it adminer sh
else ifeq "$(s)" "mailhog"
	@$(COMPOSE) exec -it mailhog sh
else
	@$(COMPOSE) exec -it $(s) bash
endif
	@:

log: ## View log (ex: make log s=access)
ifeq "$(s)" "access"
	@$(COMPOSE) exec -it proxy tail -fn100 /var/log/nginx/access.log
else ifeq "$(s)" "error"
	@$(COMPOSE) exec -it proxy tail -fn100 /var/log/nginx/error.log
else ifeq "$(s)" "clean"
	rm -f ./logs/apache/*.log
	rm -f ./logs/proxy/*.log
	rm -f ./logs/supervisor/*.log
else
	@$(COMPOSE) logs $(s)
endif
	@:

backup: ## Export all database in mysql
	@$(COMPOSE) exec -it -u root:root mysql bash /bash/backup_database.bash

restore: ## Import all database into mysql
	@$(COMPOSE) exec -it -u root:root mysql bash /bash/restore_database.bash

reload: ## Reload service (ex: make reload s=config)
ifeq "$(s)" "config"
	@$(COMPOSE) exec -it proxy nginx -s reload
	@echo "-› Reloading Proxy."
	@$(COMPOSE) exec -it apache service apache2 reload > /dev/null
	@echo "-› Reloading Apache."
else ifeq "$(s)" "worker"
	@$(COMPOSE) exec -it supervisor supervisorctl restart all
else
	$(info I renewed myself)
endif
	@:

reset-all: ## Remove all Container, Image
	@docker system prune -a

clean:
	@:

test:
	$(info Checking if custom header is needed)
	@read -p "Enter : " varl; \
	echo $$varl

_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

.PHONY: all help build clean
