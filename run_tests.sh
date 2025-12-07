#!/bin/bash

# Simple test runner for avatar system tests
# This compiles the test files and runs them directly

echo "🧪 Running Avatar System Tests..."
echo "================================="
echo ""

cd "$(dirname "$0")"

# Compile the source files and test files together
echo "📦 Compiling source and test files..."

# First, let's try a simpler approach - just compile to check for errors
xcrun swiftc \
  -sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios18.5-simulator \
  -F /Users/benh/Library/Developer/Xcode/DerivedData/IOS_Student_Haven-eiruslbzfpuqyufyzrfylrolytkm/Build/Products/Debug-iphonesimulator/PackageFrameworks \
  -I /Users/benh/Library/Developer/Xcode/DerivedData/IOS_Student_Haven-eiruslbzfpuqyufyzrfylrolytkm/Build/Products/Debug-iphonesimulator \
  -parse-as-library \
  -typecheck \
  IOS_Studeent_Haven/Models/AvatarModels.swift \
  IOS_Studeent_Haven/ViewModels/AvatarViewModel.swift \
  IOS_Student_HavenTests/AvatarModelTests.swift \
  IOS_Student_HavenTests/AvatarViewModelTests.swift 2>&1

if [ $? -eq 0 ]; then
  echo "✅ All test files compile successfully!"
  echo ""
  echo "Note: To run the tests, you need to:"
  echo "1. Add a test target in Xcode (File > New > Target > Unit Testing Bundle)"
  echo "2. Add the test files to that target"
  echo "3. Run tests with Cmd+U or: xcodebuild test -scheme IOS_Student_Haven -destination 'platform=iOS Simulator,name=iPhone 16 Plus'"
else
  echo "❌ Compilation errors found"
  exit 1
fi
