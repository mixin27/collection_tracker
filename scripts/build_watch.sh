#!/bin/bash

echo "👀 Starting build_runner in watch mode for mobile app..."
echo "Press Ctrl+C to stop"
echo ""

cd apps/mobile
flutter pub run build_runner watch --delete-conflicting-outputs
