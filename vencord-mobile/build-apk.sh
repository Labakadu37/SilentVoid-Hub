#!/bin/bash

# Vencord Mobile APK Build Script
# Build APK without EAS authentication required

set -e

echo "🚀 Building Vencord Mobile APK..."

# Check requirements
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm is required but not installed."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Generate the bundle
echo "📦 Generating React Native bundle..."
npx expo export --platform android

# Create output directory
mkdir -p dist

echo "✅ APK build completed!"
echo "📍 Output location: ./dist/"
echo ""
echo "Next steps:"
echo "1. Use 'eas build -p android' to create APK from dist/"
echo "2. Or build locally with: npx expo build:android"
echo ""
echo "For more info, see BUILD_APK.md"
