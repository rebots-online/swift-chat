#!/bin/bash
# =============================================================================
# SwiftChat Android Build Script
# Copyright (C) 2025 Robin L. M. Cheung, MBA. All rights reserved.
# =============================================================================
# Builds Android APK with versioned filename
# Usage: ./scripts/build-android.sh [release|debug]
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
echo "SwiftChat v${APP_VERSION} Android Build"
echo "${COPYRIGHT}"
echo "=============================================="
echo ""
echo "Build Type:   ${BUILD_TYPE}"
echo "Version:      ${APP_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Update Android version in build.gradle
update_android_version() {
    local gradle_file="$PROJECT_ROOT/android/app/build.gradle"
    
    # Update versionCode (use build number)
    sed -i "s/versionCode [0-9]*/versionCode ${BUILD_NUMBER}/" "$gradle_file"
    
    # Update versionName (use | as delimiter to avoid quote escaping issues)
    sed -i 's|versionName "[^"]*"|versionName "'"${APP_VERSION}"'"|' "$gradle_file"
    
    echo "Updated Android versionCode=${BUILD_NUMBER}, versionName=${APP_VERSION}"
}

# Build APK
build_apk() {
    cd "$PROJECT_ROOT/android"
    
    if [[ "$BUILD_TYPE" == "release" ]]; then
        echo "Building release APK..."
        ./gradlew assembleRelease --no-daemon
        APK_SOURCE="$PROJECT_ROOT/android/app/build/outputs/apk/release/SwiftChat.apk"
    else
        echo "Building debug APK..."
        ./gradlew assembleDebug --no-daemon
        APK_SOURCE="$PROJECT_ROOT/android/app/build/outputs/apk/debug/app-debug.apk"
    fi
    
    cd "$PROJECT_ROOT"
}

# Copy and rename APK with version
copy_versioned_apk() {
    local apk_name="SwiftChat-v${APP_VERSION}-${BUILD_NUMBER}.apk"
    
    if [[ -f "$APK_SOURCE" ]]; then
        cp "$APK_SOURCE" "$OUTPUT_DIR/$apk_name"
        echo ""
        echo "=============================================="
        echo "BUILD SUCCESSFUL"
        echo "=============================================="
        echo "Output: $OUTPUT_DIR/$apk_name"
        echo "Size:   $(du -h "$OUTPUT_DIR/$apk_name" | cut -f1)"
        echo "=============================================="
    else
        echo "ERROR: APK not found at $APK_SOURCE"
        exit 1
    fi
}

# Generate build info file
generate_build_info() {
    local info_file="$OUTPUT_DIR/build-info-android-${BUILD_NUMBER}.txt"
    cat > "$info_file" << EOF
SwiftChat Android Build Info
============================================
Version:      ${APP_VERSION}
Build Number: ${BUILD_NUMBER}
Full Version: ${FULL_VERSION}
Build Type:   ${BUILD_TYPE}
Build Date:   $(date -u +"%Y-%m-%d %H:%M:%S UTC")
${COPYRIGHT}
============================================
EOF
    echo "Build info: $info_file"
}

# Main execution
echo "Step 1/4: Updating Android version..."
update_android_version

echo ""
echo "Step 2/4: Building APK..."
build_apk

echo ""
echo "Step 3/4: Copying versioned APK..."
copy_versioned_apk

echo ""
echo "Step 4/4: Generating build info..."
generate_build_info

echo ""
echo "Android build complete!"
