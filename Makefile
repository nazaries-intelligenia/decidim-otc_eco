.PHONY: help build build-prod up up-prod down shell shell-prod console console-prod logs logs-prod test rubocop clear-cache db-setup db-reset

.DEFAULT_GOAL := help
PROJECTNAME := otceco
COMPOSE_DEV := docker compose
COMPOSE_PROD := docker compose -p $(PROJECTNAME)-production-test -f docker-compose.production-test.yml

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Build Commands
build: ## Build development containers
	$(COMPOSE_DEV) build

build-prod: ## Build production-test containers
	$(COMPOSE_PROD) build

# Container Management - Development
up: ## Start development containers
	$(COMPOSE_DEV) up

up-detached: ## Start development containers in background
	$(COMPOSE_DEV) up -d

up-db: ## Start only database container (development)
	$(COMPOSE_DEV) up db

up-db-detached: ## Start only database container in background (development)
	$(COMPOSE_DEV) up -d db

# Container Management - Production Test
up-prod: ## Start production-test containers
	$(COMPOSE_PROD) up

up-prod-detached: ## Start production-test containers in background
	$(COMPOSE_PROD) up -d

up-db-prod: ## Start only database container (production-test)
	$(COMPOSE_PROD) up db

up-db-prod-detached: ## Start only database container in background (production-test)
	$(COMPOSE_PROD) up -d db

# Stop Containers
down: ## Stop and remove all containers
	$(COMPOSE_DEV) down --remove-orphans
	$(COMPOSE_PROD) down --remove-orphans

# Shell Commands - Development
shell: ## Open bash shell in development container
	$(COMPOSE_DEV) run --rm -it web bash

console: ## Open Rails console in development
	$(COMPOSE_DEV) run --rm -it web rails console

# Shell Commands - Production Test
shell-prod: ## Open bash shell in production-test container
	$(COMPOSE_PROD) run --rm -it app bash

console-prod: ## Open Rails console in production-test
	$(COMPOSE_PROD) run --rm -it app rails console

# Logs - Development
logs: ## Show and follow development logs
	$(COMPOSE_DEV) logs -f web

# Logs - Production Test
logs-prod: ## Show and follow production-test logs
	$(COMPOSE_PROD) logs -f web

# Cache Commands
clear-cache: ## Clear Rails cache
	$(COMPOSE_DEV) exec web rails runner "Rails.cache.clear; puts '✓ Cache cleared'"

# Database Commands
db-setup: ## Setup database
	$(COMPOSE_DEV) run --rm web bundle exec rails db:setup

db-migrate: ## Run database migrations
	$(COMPOSE_DEV) run --rm web bundle exec rails db:migrate

db-rollback: ## Rollback last migration
	$(COMPOSE_DEV) run --rm web bundle exec rails db:rollback

db-reset: ## Reset database
	$(COMPOSE_DEV) run --rm web bundle exec rails db:reset

db-seed: ## Seed database
	$(COMPOSE_DEV) run --rm web bundle exec rails db:seed

# Testing Commands
test: ## Run all tests
	$(COMPOSE_DEV) run --rm web bundle exec rails test

test-models: ## Run model tests
	$(COMPOSE_DEV) run --rm web bundle exec rails test test/models/

test-controllers: ## Run controller tests
	$(COMPOSE_DEV) run --rm web bundle exec rails test test/controllers/

test-system: ## Run system tests
	$(COMPOSE_DEV) run --rm web bundle exec rails test:system

test-file: ## Run specific test file (usage: make test-file FILE=test/models/user_test.rb)
	$(COMPOSE_DEV) run --rm web bundle exec rails test $(FILE)

# Code Quality
rubocop: ## Run RuboCop linter
	$(COMPOSE_DEV) run --rm web bundle exec rubocop

rubocop-fix: ## Run RuboCop with auto-fix
	$(COMPOSE_DEV) run --rm web bundle exec rubocop -A

# Volume Management
wipe-volumes-dev: ## Delete all development volumes (WARNING: destroys data)
	$(COMPOSE_DEV) down --volumes --remove-orphans

wipe-volumes-prod: ## Delete all production-test volumes (WARNING: destroys data)
	$(COMPOSE_PROD) down --volumes --remove-orphans

