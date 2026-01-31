#!/bin/bash
# =============================================================================
# SwiftChat Full Build Script
# Copyright (C) 2025 Robin L. M. Cheung, MBA. All rights reserved.
# =============================================================================
# Builds all platforms with versioned output
# Usage: ./scripts/build-all.sh [release|debug]
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source version utility
source "$SCRIPT_DIR/version.sh"

BUILD_TYPE="${1:-release}"
OUTPUT_DIR="$PROJECT_ROOT/build-output"

echo ""
echo "=============================================="
echo "SwiftChat v${APP_VERSION} Full Build"
echo "${COPYRIGHT}"
echo "=============================================="
echo ""
echo "Build Type:   ${BUILD_TYPE}"
echo "Version:      ${APP_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"
echo "Platforms:    Android, iOS, macOS"
echo ""

# Detect available platforms
AVAILABLE_PLATFORMS=()

# Android is available on Linux/macOS if ANDROID_HOME is set
if [[ -n "$ANDROID_HOME" ]] || [[ -d "$HOME/Android/Sdk" ]] || [[ -d "$HOME/Library/Android/sdk" ]]; then
    AVAILABLE_PLATFORMS+=("android")
fi

# iOS/macOS only available on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    if command -v xcodebuild &> /dev/null; then
        AVAILABLE_PLATFORMS+=("ios")
        AVAILABLE_PLATFORMS+=("macos")
    fi
fi

if [[ ${#AVAILABLE_PLATFORMS[@]} -eq 0 ]]; then
    echo "ERROR: No build platforms available."
    echo "  - Android: Set ANDROID_HOME or install Android SDK"
    echo "  - iOS/macOS: Requires macOS with Xcode"
    exit 1
fi

echo "Available platforms: ${AVAILABLE_PLATFORMS[*]}"
echo ""

# Build each platform
build_results=()

for platform in "${AVAILABLE_PLATFORMS[@]}"; do
    echo ""
    echo "=============================================="
    echo "Building ${platform^^}..."
    echo "=============================================="
    
    case $platform in
        android)
            if "$SCRIPT_DIR/build-android.sh" "$BUILD_TYPE"; then
                build_results+=("Android: SUCCESS")
            else
                build_results+=("Android: FAILED")
            fi
            ;;
        ios)
            if "$SCRIPT_DIR/build-ios.sh" "ios" "$BUILD_TYPE"; then
                build_results+=("iOS: SUCCESS")
            else
                build_results+=("iOS: FAILED")
            fi
            ;;
        macos)
            if "$SCRIPT_DIR/build-ios.sh" "macos" "$BUILD_TYPE"; then
                build_results+=("macOS: SUCCESS")
            else
                build_results+=("macOS: FAILED")
            fi
            ;;
    esac
done

# Summary
echo ""
echo "=============================================="
echo "BUILD SUMMARY"
echo "=============================================="
echo "SwiftChat v${APP_VERSION} (Build ${BUILD_NUMBER})"
echo "${COPYRIGHT}"
echo "----------------------------------------------"
for result in "${build_results[@]}"; do
    echo "  $result"
done
echo "----------------------------------------------"
echo "Output directory: $OUTPUT_DIR"
echo ""
ls -la "$OUTPUT_DIR" 2>/dev/null || true
echo "=============================================="
