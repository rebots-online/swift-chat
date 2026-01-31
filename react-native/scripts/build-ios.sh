#!/bin/bash
# =============================================================================
# SwiftChat iOS/macOS Build Script
# Copyright (C) 2025 Robin L. M. Cheung, MBA. All rights reserved.
# =============================================================================
# Builds iOS/macOS app with versioned output
# Usage: ./scripts/build-ios.sh [ios|macos] [release|debug]
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source version utility
source "$SCRIPT_DIR/version.sh"

PLATFORM="${1:-ios}"
BUILD_TYPE="${2:-release}"
OUTPUT_DIR="$PROJECT_ROOT/build-output"
WORKSPACE="$PROJECT_ROOT/ios/SwiftChat.xcworkspace"
SCHEME="SwiftChat"

echo ""
echo "=============================================="
echo "SwiftChat v${APP_VERSION} ${PLATFORM^^} Build"
echo "${COPYRIGHT}"
echo "=============================================="
echo ""
echo "Platform:     ${PLATFORM}"
echo "Build Type:   ${BUILD_TYPE}"
echo "Version:      ${APP_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Update iOS/macOS version in project
update_ios_version() {
    local project_file="$PROJECT_ROOT/ios/SwiftChat.xcodeproj/project.pbxproj"
    
    # Update MARKETING_VERSION (display version)
    sed -i 's|MARKETING_VERSION = [^;]*|MARKETING_VERSION = '"${APP_VERSION}"'|' "$project_file"
    
    # Update CURRENT_PROJECT_VERSION (build number)
    sed -i 's|CURRENT_PROJECT_VERSION = [^;]*|CURRENT_PROJECT_VERSION = '"${BUILD_NUMBER}"'|' "$project_file"
    
    echo "Updated iOS MARKETING_VERSION=${APP_VERSION}, CURRENT_PROJECT_VERSION=${BUILD_NUMBER}"
}

# Build for iOS
build_ios() {
    local config="Release"
    [[ "$BUILD_TYPE" == "debug" ]] && config="Debug"
    
    echo "Building iOS app (${config})..."
    
    xcodebuild -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphoneos \
        -configuration "$config" \
        -destination "generic/platform=iOS" \
        -archivePath "$OUTPUT_DIR/SwiftChat-iOS.xcarchive" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        clean archive | xcpretty || xcodebuild -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -sdk iphoneos \
        -configuration "$config" \
        -destination "generic/platform=iOS" \
        -archivePath "$OUTPUT_DIR/SwiftChat-iOS.xcarchive" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        clean archive
}

# Build for macOS (Mac Catalyst)
build_macos() {
    local config="Release"
    [[ "$BUILD_TYPE" == "debug" ]] && config="Debug"
    
    echo "Building macOS app (${config})..."
    
    xcodebuild -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -destination "platform=macOS,variant=Mac Catalyst" \
        -configuration "$config" \
        -archivePath "$OUTPUT_DIR/SwiftChat-macOS.xcarchive" \
        CODE_SIGN_IDENTITY="-" \
        clean archive 2>&1 | xcpretty || xcodebuild -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -destination "platform=macOS,variant=Mac Catalyst" \
        -configuration "$config" \
        -archivePath "$OUTPUT_DIR/SwiftChat-macOS.xcarchive" \
        CODE_SIGN_IDENTITY="-" \
        clean archive
}

# Export and rename with version
export_app() {
    local archive_name="SwiftChat-${PLATFORM}-v${APP_VERSION}-${BUILD_NUMBER}"
    
    if [[ "$PLATFORM" == "ios" ]]; then
        local archive_path="$OUTPUT_DIR/SwiftChat-iOS.xcarchive"
        if [[ -d "$archive_path" ]]; then
            mv "$archive_path" "$OUTPUT_DIR/${archive_name}.xcarchive"
            echo ""
            echo "=============================================="
            echo "BUILD SUCCESSFUL"
            echo "=============================================="
            echo "Output: $OUTPUT_DIR/${archive_name}.xcarchive"
            echo "=============================================="
        fi
    else
        local archive_path="$OUTPUT_DIR/SwiftChat-macOS.xcarchive"
        if [[ -d "$archive_path" ]]; then
            # Extract .app from archive
            local app_path="${archive_path}/Products/Applications/SwiftChat.app"
            if [[ -d "$app_path" ]]; then
                local dmg_name="${archive_name}.dmg"
                
                # Create DMG
                echo "Creating DMG..."
                hdiutil create -volname "SwiftChat" \
                    -srcfolder "$app_path" \
                    -ov -format UDZO \
                    "$OUTPUT_DIR/$dmg_name" 2>/dev/null || {
                    # Fallback: just copy the archive
                    mv "$archive_path" "$OUTPUT_DIR/${archive_name}.xcarchive"
                    echo "DMG creation failed, archive saved instead"
                }
                
                if [[ -f "$OUTPUT_DIR/$dmg_name" ]]; then
                    echo ""
                    echo "=============================================="
                    echo "BUILD SUCCESSFUL"
                    echo "=============================================="
                    echo "Output: $OUTPUT_DIR/$dmg_name"
                    echo "Size:   $(du -h "$OUTPUT_DIR/$dmg_name" | cut -f1)"
                    echo "=============================================="
                fi
            fi
            
            mv "$archive_path" "$OUTPUT_DIR/${archive_name}.xcarchive" 2>/dev/null || true
        fi
    fi
}

# Generate build info file
generate_build_info() {
    local info_file="$OUTPUT_DIR/build-info-${PLATFORM}-${BUILD_NUMBER}.txt"
    cat > "$info_file" << EOF
SwiftChat ${PLATFORM^^} Build Info
============================================
Version:      ${APP_VERSION}
Build Number: ${BUILD_NUMBER}
Full Version: ${FULL_VERSION}
Platform:     ${PLATFORM}
Build Type:   ${BUILD_TYPE}
Build Date:   $(date -u +"%Y-%m-%d %H:%M:%S UTC")
${COPYRIGHT}
============================================
EOF
    echo "Build info: $info_file"
}

# Main execution
echo "Step 1/4: Updating iOS/macOS version..."
update_ios_version

echo ""
echo "Step 2/4: Building app..."
if [[ "$PLATFORM" == "ios" ]]; then
    build_ios
else
    build_macos
fi

echo ""
echo "Step 3/4: Exporting versioned app..."
export_app

echo ""
echo "Step 4/4: Generating build info..."
generate_build_info

echo ""
echo "${PLATFORM^^} build complete!"
