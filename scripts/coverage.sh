#!/bin/bash
set -e

echo "📊 Generating test coverage report..."
echo ""

cd apps/mobile

# Remove old coverage data
rm -rf coverage

# Run tests with coverage
flutter test --coverage

if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

# Check if genhtml is installed (part of lcov)
if command -v genhtml &> /dev/null; then
    echo ""
    echo "Generating HTML coverage report..."
    genhtml coverage/lcov.info -o coverage/html

    echo ""
    echo "✅ Coverage report generated!"
    echo "Open coverage/html/index.html in your browser"
else
    echo ""
    echo "✅ Coverage data generated in coverage/lcov.info"
    echo ""
    echo "To generate HTML report, install lcov:"
    echo "  macOS: brew install lcov"
    echo "  Ubuntu: sudo apt-get install lcov"
fi

cd - > /dev/null
