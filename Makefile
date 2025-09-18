# Open Source SEI Platform - Makefile
# Development and deployment automation

.PHONY: help install dev test build deploy clean docs lint format

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Development Setup
install: ## Install all dependencies and setup development environment
	@echo "🚀 Setting up SEI Platform development environment..."
	@echo "📦 Installing Python dependencies..."
	pip install -r requirements.txt
	@echo "📦 Installing Node.js dependencies..."
	cd src/frontend && npm install
	@echo "🐳 Building Docker images..."
	docker-compose build
	@echo "✅ Installation complete!"

dev: ## Start development environment with Docker Compose
	@echo "🚀 Starting development environment..."
	docker-compose up -d
	@echo "⏳ Waiting for services to be ready..."
	sleep 30
	@echo "🌐 Services available at:"
	@echo "  - Frontend: http://localhost:3002"
	@echo "  - API: http://localhost:8080"
	@echo "  - Metabase: http://localhost:3000"
	@echo "  - Grafana: http://localhost:3001"
	@echo "  - Airflow: http://localhost:8082"
	@echo "  - Kafka UI: http://localhost:8083"
	@echo "  - PgAdmin: http://localhost:8084"
	@echo "✅ Development environment ready!"

dev-logs: ## Follow logs from all development services
	docker-compose logs -f

dev-stop: ## Stop development environment
	@echo "🛑 Stopping development environment..."
	docker-compose down
	@echo "✅ Development environment stopped!"

dev-restart: ## Restart development environment
	@echo "🔄 Restarting development environment..."
	docker-compose restart
	@echo "✅ Development environment restarted!"

# Testing
test: ## Run all tests
	@echo "🧪 Running all tests..."
	@echo "📊 Running Python tests..."
	python -m pytest src/tests/ -v --cov=src --cov-report=html
	@echo "🌐 Running frontend tests..."
	cd src/frontend && npm test
	@echo "📈 Running integration tests..."
	python -m pytest src/tests/integration/ -v
	@echo "✅ All tests completed!"

test-unit: ## Run unit tests only
	@echo "🧪 Running unit tests..."
	python -m pytest src/tests/unit/ -v

test-integration: ## Run integration tests only
	@echo "🧪 Running integration tests..."
	python -m pytest src/tests/integration/ -v

test-e2e: ## Run end-to-end tests
	@echo "🧪 Running E2E tests..."
	cd src/tests/e2e && npm test

test-load: ## Run load tests
	@echo "🧪 Running load tests..."
	cd src/tests/load && locust -f locustfile.py --headless -u 100 -r 10 -t 300s --host=http://localhost:8080

# Code Quality
lint: ## Run linting on all code
	@echo "🔍 Running linters..."
	@echo "🐍 Linting Python code..."
	flake8 src/ --max-line-length=100
	pylint src/ --rcfile=.pylintrc
	@echo "🌐 Linting JavaScript/TypeScript code..."
	cd src/frontend && npm run lint
	@echo "🐳 Linting Dockerfiles..."
	docker run --rm -i hadolint/hadolint < Dockerfile
	@echo "✅ Linting completed!"

format: ## Format all code
	@echo "✨ Formatting code..."
	@echo "🐍 Formatting Python code..."
	black src/ --line-length=100
	isort src/ --profile=black
	@echo "🌐 Formatting JavaScript/TypeScript code..."
	cd src/frontend && npm run format
	@echo "✅ Code formatting completed!"

security: ## Run security scans
	@echo "🔒 Running security scans..."
	@echo "🐍 Scanning Python dependencies..."
	safety check
	bandit -r src/ -f json -o reports/bandit-report.json
	@echo "🌐 Scanning Node.js dependencies..."
	cd src/frontend && npm audit
	@echo "🐳 Scanning Docker images..."
	docker scout cves
	@echo "✅ Security scans completed!"

# Build
build: ## Build all services for production
	@echo "🏗️ Building production images..."
	docker-compose -f docker-compose.prod.yml build
	@echo "✅ Build completed!"

build-frontend: ## Build frontend only
	@echo "🏗️ Building frontend..."
	cd src/frontend && npm run build
	@echo "✅ Frontend build completed!"

build-api: ## Build API services only
	@echo "🏗️ Building API services..."
	docker build -t sei-api-service src/apis/
	@echo "✅ API build completed!"

build-collectors: ## Build data collectors
	@echo "🏗️ Building data collectors..."
	docker build -t sei-git-collector src/collectors/git/
	docker build -t sei-jira-collector src/collectors/jira/
	@echo "✅ Collectors build completed!"

# Deployment
deploy-local: ## Deploy to local Kubernetes (minikube/kind)
	@echo "🚀 Deploying to local Kubernetes..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/
	@echo "✅ Local deployment completed!"

deploy-staging: ## Deploy to staging environment
	@echo "🚀 Deploying to staging..."
	@echo "📦 Building and pushing images..."
	docker-compose -f docker-compose.prod.yml build
	docker-compose -f docker-compose.prod.yml push
	@echo "🎯 Deploying to staging cluster..."
	kubectl apply -f k8s/staging/
	@echo "✅ Staging deployment completed!"

deploy-prod: ## Deploy to production environment
	@echo "🚀 Deploying to production..."
	@echo "⚠️  WARNING: Deploying to production!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "📦 Building and pushing production images..."
	docker-compose -f docker-compose.prod.yml build
	docker-compose -f docker-compose.prod.yml push
	@echo "🎯 Deploying to production cluster..."
	kubectl apply -f k8s/production/
	@echo "✅ Production deployment completed!"

# Database Management
db-migrate: ## Run database migrations
	@echo "📊 Running database migrations..."
	python src/database/migrate.py
	@echo "✅ Migrations completed!"

db-seed: ## Seed database with sample data
	@echo "🌱 Seeding database with sample data..."
	python src/database/seed.py
	@echo "✅ Database seeded!"

db-backup: ## Backup databases
	@echo "💾 Creating database backups..."
	./scripts/backup-databases.sh
	@echo "✅ Backup completed!"

db-restore: ## Restore databases from backup
	@echo "🔄 Restoring databases from backup..."
	./scripts/restore-databases.sh
	@echo "✅ Restore completed!"

# Monitoring and Observability
monitor: ## Start monitoring stack
	@echo "📊 Starting monitoring stack..."
	docker-compose -f docker-compose.monitoring.yml up -d
	@echo "📈 Monitoring available at:"
	@echo "  - Grafana: http://localhost:3001"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - AlertManager: http://localhost:9093"

logs: ## Tail logs from all services
	@echo "📋 Tailing logs from all services..."
	docker-compose logs -f

logs-api: ## Tail API service logs
	docker-compose logs -f api-service

logs-collectors: ## Tail data collector logs
	docker-compose logs -f git-collector jira-collector

logs-processors: ## Tail data processor logs
	docker-compose logs -f data-processor

# Data Operations
data-collect: ## Trigger data collection manually
	@echo "📥 Triggering manual data collection..."
	curl -X POST http://localhost:8080/api/v1/collect/trigger
	@echo "✅ Data collection triggered!"

data-process: ## Trigger data processing manually
	@echo "⚙️ Triggering manual data processing..."
	curl -X POST http://localhost:8080/api/v1/process/trigger
	@echo "✅ Data processing triggered!"

data-export: ## Export data for analysis
	@echo "📤 Exporting data..."
	python scripts/export-data.py --format csv --output ./exports/
	@echo "✅ Data exported to ./exports/"

# Utilities
clean: ## Clean up development environment
	@echo "🧹 Cleaning up development environment..."
	docker-compose down -v
	docker system prune -f
	docker volume prune -f
	@echo "✅ Cleanup completed!"

clean-builds: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} +
	rm -rf src/frontend/build/
	rm -rf src/frontend/node_modules/
	rm -rf .pytest_cache/
	rm -rf htmlcov/
	@echo "✅ Build cleanup completed!"

reset: ## Reset entire development environment
	@echo "🔄 Resetting development environment..."
	make clean
	make clean-builds
	make install
	make dev
	@echo "✅ Environment reset completed!"

# Documentation
docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	@echo "📖 Generating API documentation..."
	cd src/apis && python -m sphinx.cmd.build -b html docs docs/_build
	@echo "🎨 Generating frontend documentation..."
	cd src/frontend && npm run docs
	@echo "📋 Generating database schema documentation..."
	python scripts/generate-schema-docs.py
	@echo "✅ Documentation generated!"

docs-serve: ## Serve documentation locally
	@echo "📚 Serving documentation at http://localhost:8085"
	cd docs && python -m http.server 8085

# Configuration
config-dev: ## Generate development configuration
	@echo "⚙️ Generating development configuration..."
	cp config/dev.env.example .env
	python scripts/generate-config.py --env=development
	@echo "✅ Development configuration ready!"

config-prod: ## Generate production configuration
	@echo "⚙️ Generating production configuration..."
	python scripts/generate-config.py --env=production
	@echo "✅ Production configuration ready!"

# SSL/TLS
ssl-generate: ## Generate SSL certificates for development
	@echo "🔐 Generating SSL certificates..."
	./scripts/generate-ssl.sh
	@echo "✅ SSL certificates generated!"

# Performance
perf-test: ## Run performance tests
	@echo "🚄 Running performance tests..."
	cd src/tests/performance && python run_performance_tests.py
	@echo "✅ Performance tests completed!"

perf-profile: ## Profile application performance
	@echo "📊 Profiling application..."
	python -m cProfile -o profile.stats src/main.py
	python scripts/analyze-profile.py profile.stats
	@echo "✅ Profiling completed!"

# Kubernetes Operations
k8s-status: ## Check Kubernetes deployment status
	@echo "📊 Checking Kubernetes status..."
	kubectl get pods -n sei-platform
	kubectl get services -n sei-platform
	kubectl get ingress -n sei-platform

k8s-logs: ## Get Kubernetes pod logs
	@echo "📋 Getting Kubernetes logs..."
	kubectl logs -n sei-platform -l app=sei-platform --tail=100

k8s-scale: ## Scale Kubernetes deployment
	@echo "📈 Scaling deployment..."
	kubectl scale deployment sei-api-service --replicas=3 -n sei-platform
	@echo "✅ Scaling completed!"

k8s-rollback: ## Rollback Kubernetes deployment
	@echo "🔄 Rolling back deployment..."
	kubectl rollout undo deployment/sei-api-service -n sei-platform
	@echo "✅ Rollback completed!"

# Backup and Recovery
backup-full: ## Create full system backup
	@echo "💾 Creating full system backup..."
	./scripts/backup-full.sh
	@echo "✅ Full backup completed!"

restore-full: ## Restore from full system backup
	@echo "🔄 Restoring from full system backup..."
	./scripts/restore-full.sh
	@echo "✅ Full restore completed!"

# Development Helpers
shell-api: ## Open shell in API container
	docker-compose exec api-service /bin/bash

shell-db: ## Open shell in database container
	docker-compose exec timescaledb psql -U sei_user -d sei_platform

shell-redis: ## Open shell in Redis container
	docker-compose exec redis redis-cli

jupyter: ## Start Jupyter notebook for data analysis
	@echo "📊 Starting Jupyter notebook..."
	docker run -it --rm -p 8888:8888 -v $(PWD)/notebooks:/home/jovyan/work jupyter/datascience-notebook
	@echo "📊 Jupyter available at: http://localhost:8888"

# Git Hooks
hooks-install: ## Install Git hooks
	@echo "🎣 Installing Git hooks..."
	cp scripts/hooks/* .git/hooks/
	chmod +x .git/hooks/*
	@echo "✅ Git hooks installed!"

# Project Information
version: ## Show project version
	@echo "📋 SEI Platform Information:"
	@echo "Version: $(shell cat VERSION)"
	@echo "Build: $(shell git rev-parse --short HEAD)"
	@echo "Branch: $(shell git branch --show-current)"

status: ## Show project status
	@echo "📊 Project Status:"
	@echo "Git Status:"
	@git status --porcelain
	@echo ""
	@echo "Docker Status:"
	@docker-compose ps
	@echo ""
	@echo "Service Health:"
	@curl -s http://localhost:8080/health || echo "API: Not Running"

# Quick Start for New Developers
quickstart: ## Complete setup for new developers
	@echo "🚀 Quick Start for SEI Platform Development"
	@echo "👨‍💻 Setting up everything for new developers..."
	make install
	make config-dev
	make dev
	make db-migrate
	make db-seed
	@echo ""
	@echo "✅ Quick start completed!"
	@echo "🌐 Your development environment is ready:"
	@echo "  - Frontend: http://localhost:3002"
	@echo "  - API: http://localhost:8080"
	@echo "  - Grafana: http://localhost:3001 (admin/admin123)"
	@echo "  - Metabase: http://localhost:3000"
	@echo ""
	@echo "📚 Next steps:"
	@echo "  1. Check 'make help' for available commands"
	@echo "  2. Read docs/CONTRIBUTING.md"
	@echo "  3. Visit http://localhost:3002 to see the platform"
	@echo ""
	@echo "🎉 Happy coding!"