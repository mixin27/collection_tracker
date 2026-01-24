.PHONY: setup clean build test analyze run help doctor format coverage

help:
	@echo "Collection Tracker - Available commands:"
	@echo "  make setup      - Setup workspace and get dependencies"
	@echo "  make clean      - Clean all packages"
	@echo "  make build      - Run code generation for all packages"
	@echo "  make test       - Run tests for all packages"
	@echo "  make analyze    - Analyze all packages"
	@echo "  make format     - Format all code"
	@echo "  make run        - Run the mobile app"
	@echo "  make coverage   - Generate test coverage"
	@echo "  make doctor     - Run flutter doctor"
# 	@echo ""
# 	@echo "Docker commands:"
# 	@echo "  make docker-build      - Build production Docker image"
# 	@echo "  make docker-build-dev  - Build development Docker image"
# 	@echo "  make docker-dev        - Start development environment"
# 	@echo "  make docker-test       - Run tests in Docker"
# 	@echo "  make docker-build-apk  - Build APK using Docker"

setup:
	@echo "🚀 Setting up workspace..."
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

clean:
	@echo "🧹 Cleaning workspace..."
	@./scripts/clean_all.sh

build:
	@echo "🔨 Running code generation..."
	@./scripts/build_all.sh

test:
	@echo "🧪 Running tests..."
	@./scripts/test_all.sh

analyze:
	@echo "🔍 Analyzing code..."
	@./scripts/analyze_all.sh

format:
	@echo "✨ Formatting code..."
	@./scripts/format_all.sh

run:
	@echo "📱 Running mobile app..."
	@cd apps/mobile && flutter run

watch:
	@echo "👀 Watching for changes..."
	@cd apps/mobile && flutter pub run build_runner watch --delete-conflicting-outputs

doctor:
	@echo "🏥 Running flutter doctor..."
	@flutter doctor -v

coverage:
	@echo "📊 Generating coverage..."
	@./scripts/coverage.sh

# Docker targets
# docker-build:
# 	@echo "🐳 Building production Docker image..."
# 	@docker build -t collection_tracker:latest .

# docker-build-dev:
# 	@echo "🐳 Building development Docker image..."
# 	@docker build -f Dockerfile.dev -t collection_tracker:dev .

# docker-build-ci:
# 	@echo "🐳 Building CI Docker image..."
# 	@docker build -f Dockerfile.ci -t collection_tracker:ci .

# docker-dev:
# 	@echo "🐳 Starting development environment..."
# 	@docker-compose up -d flutter-dev
# 	@docker-compose exec flutter-dev /bin/bash

# docker-ci:
# 	@echo "🐳 Running CI tests..."
# 	@docker-compose up flutter-ci

# docker-run:
# 	@echo "🐳 Running app in Docker..."
# 	@docker run --rm -v $(PWD):/workspace -w /workspace collection_tracker:dev \
# 		bash -c "cd apps/mobile && flutter run -d web-server --web-port=8080"

# docker-test:
# 	@echo "🐳 Running tests in Docker..."
# 	@docker run --rm -v $(PWD):/workspace -w /workspace collection_tracker:dev \
# 		./scripts/test_all.sh

# docker-analyze:
# 	@echo "🐳 Analyzing code in Docker..."
# 	@docker run --rm -v $(PWD):/workspace -w /workspace collection_tracker:dev \
# 		./scripts/analyze_all.sh

# docker-build-apk:
# 	@echo "🐳 Building APK in Docker..."
# 	@docker run --rm -v $(PWD):/workspace -w /workspace collection_tracker:dev \
# 		bash -c "cd apps/mobile && flutter build apk --release"

# docker-shell:
# 	@echo "🐳 Opening shell in Docker..."
# 	@docker run --rm -it -v $(PWD):/workspace -w /workspace collection_tracker:dev /bin/bash

# docker-clean:
# 	@echo "🐳 Cleaning Docker resources..."
# 	@docker-compose down -v
# 	@docker rmi collection_tracker:latest collection_tracker:dev collection_tracker:ci 2>/dev/null || true

# Build targets
build-apk:
	@echo "📦 Building Android APK..."
	@cd apps/mobile && flutter build apk --release

build-appbundle:
	@echo "📦 Building Android App Bundle..."
	@cd apps/mobile && flutter build appbundle --release

build-ios:
	@echo "📦 Building iOS..."
	@cd apps/mobile && flutter build ios --release

build-web:
	@echo "📦 Building Web..."
	@cd apps/mobile && flutter build web --release
