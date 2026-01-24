#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: ./scripts/create_package.sh <category> <package_name>"
    echo "Categories: core, common, integrations"
    echo "Example: ./scripts/create_package.sh integrations notification"
    exit 1
fi

CATEGORY=$1
PACKAGE_NAME=$2
PACKAGE_DIR="packages/$CATEGORY/$PACKAGE_NAME"

if [ -d "$PACKAGE_DIR" ]; then
    echo "❌ Package already exists: $PACKAGE_DIR"
    exit 1
fi

echo "📦 Creating new package: $CATEGORY/$PACKAGE_NAME"
echo ""

# Create package directory structure
mkdir -p "$PACKAGE_DIR"/{lib,test}

# Create pubspec.yaml
cat > "$PACKAGE_DIR/pubspec.yaml" << EOF
name: ${CATEGORY}_${PACKAGE_NAME}
description: ${PACKAGE_NAME} package
version: 1.0.0
publish_to: 'none'

environment:
  sdk: ^3.10.4
  flutter: ">=1.17.0"

dependencies:
  # Add your dependencies here

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
EOF

# Create lib file
mkdir -p "$PACKAGE_DIR/lib/src"

cat > "$PACKAGE_DIR/lib/${CATEGORY}_${PACKAGE_NAME}.dart" << EOF
library ${CATEGORY}_${PACKAGE_NAME};

// Export your public API here
EOF

# Create README
cat > "$PACKAGE_DIR/README.md" << EOF
# ${CATEGORY}_${PACKAGE_NAME}

${PACKAGE_NAME} package for Collection Tracker

## Usage

\`\`\`dart
import 'package:${CATEGORY}_${PACKAGE_NAME}/${CATEGORY}_${PACKAGE_NAME}.dart';
\`\`\`
EOF

# Create test file
cat > "$PACKAGE_DIR/test/${PACKAGE_NAME}_test.dart" << EOF
import 'package:test/test.dart';
import 'package:${CATEGORY}_${PACKAGE_NAME}/${CATEGORY}_${PACKAGE_NAME}.dart';

void main() {
  group('${PACKAGE_NAME}', () {
    test('initial test', () {
      // TODO: Add tests
      expect(true, isTrue);
    });
  });
}
EOF

# Create analysis_options.yaml
cat > "$PACKAGE_DIR/analysis_options.yaml" << EOF
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_print
EOF

echo "✅ Package created successfully!"
echo ""
echo "Package location: $PACKAGE_DIR"
echo ""
echo "Next steps:"
echo "  1. Add the package to workspace in root pubspec.yaml"
echo "  2. Run 'dart pub get' from workspace root"
echo "  3. Start developing in $PACKAGE_DIR/lib/"
