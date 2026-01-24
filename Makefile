.PHONY: setup clean build test analyze run help

help:
	@echo "Collection Tracker - Available commands:"
	@echo "  make setup    - Setup workspace and get dependencies"
	@echo "  make clean    - Clean all packages"
	@echo "  make build    - Run code generation for all packages"
	@echo "  make test     - Run tests for all packages"
	@echo "  make analyze  - Analyze all packages"
	@echo "  make run      - Run the mobile app"

setup:
	@echo "Setting up workspace..."
	dart pub get
	@$(MAKE) build

clean:
	@echo "Cleaning workspace..."
	cd apps/mobile && flutter clean
	find packages -name ".dart_tool" -type d -exec rm -rf {} +
	@echo "Clean complete!"

build:
	@echo "Running code generation..."
	cd packages/core/domain && dart run build_runner build --delete-conflicting-outputs
	cd packages/core/data && dart run build_runner build --delete-conflicting-outputs
	cd packages/integrations/metadata_api && dart run build_runner build --delete-conflicting-outputs
	cd apps/mobile && flutter pub run build_runner build --delete-conflicting-outputs
	@echo "Build complete!"

test:
	@echo "Running tests..."
	cd packages/core/domain && dart test
	cd packages/core/data && dart test
	cd apps/mobile && flutter test
	@echo "Tests complete!"

analyze:
	@echo "Analyzing code..."
	cd apps/mobile && flutter analyze
	cd packages/core/domain && dart analyze
	cd packages/core/data && dart analyze
	@echo "Analysis complete!"

run:
	cd apps/mobile && flutter run

watch:
	cd apps/mobile && flutter pub run build_runner watch --delete-conflicting-outputs
