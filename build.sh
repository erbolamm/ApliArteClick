#!/bin/bash

# Define the app name
APP_NAME="AutoClicker"

# Create a build directory
mkdir -p build

# Compile the Swift files
# Note: This is a simple compilation for a SwiftUI app. 
# For a full .app bundle, more steps are required, but this binary can run.
swiftc -o build/$APP_NAME \
    AutoClicker.swift \
    ContentView.swift \
    click_macApp.swift \
    -framework SwiftUI \
    -framework AppKit \
    -parse-as-library

if [ $? -eq 0 ]; then
    echo "Build successful! You can run the app with: ./build/$APP_NAME"
    echo "IMPORTANT: You may need to grant Accessibility permissions in System Settings."
else
    echo "Build failed."
fi
