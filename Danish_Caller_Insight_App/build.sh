#!/bin/bash

# Danish Caller Insight - Build Script

echo "🏗️  Building Danish Caller Insight..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Get Flutter version
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
print_status "Flutter version: $FLUTTER_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Generate code (if using code generation)
print_status "Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
print_status "Running tests..."
flutter test

if [ $? -ne 0 ]; then
    print_error "Tests failed!"
    exit 1
fi

# Build APK
print_status "Building APK..."
flutter build apk --release --split-per-abi

if [ $? -eq 0 ]; then
    print_status "APK build completed successfully!"
    print_status "APK files are in: build/app/outputs/flutter-apk/"
else
    print_error "APK build failed!"
    exit 1
fi

# Build App Bundle
print_status "Building App Bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    print_status "App Bundle build completed successfully!"
    print_status "App Bundle is in: build/app/outputs/bundle/release/"
else
    print_error "App Bundle build failed!"
    exit 1
fi

# Generate documentation
print_status "Generating documentation..."
flutter pub global activate dartdoc
flutter pub global run dartdoc

print_status "Build process completed! 🎉"
print_status "Next steps:"
echo "1. Upload the App Bundle to Google Play Console"
echo "2. Test the release build on physical devices"
echo "3. Monitor Firebase Analytics and Crashlytics"
echo "4. Respond to user feedback and reviews"