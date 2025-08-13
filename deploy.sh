#!/bin/bash

# Get current version
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')

# Update version file
echo "{\"version\":\"$VERSION\",\"build_time\":\"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"}" > web/version.json

# Build Flutter web
flutter build web --release --pwa-strategy=none

# Deploy to Firebase
firebase deploy --only hosting

echo "Version $VERSION deployed successfully!"