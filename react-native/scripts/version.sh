#!/bin/bash
# =============================================================================
# SwiftChat Build Version Utility
# Copyright (C) 2025 Robin L. M. Cheung, MBA. All rights reserved.
# =============================================================================
# Generates version and epoch-based 5-digit build number
# Usage: source scripts/version.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Read version from package.json (match only the top-level version field)
get_version() {
    grep -m1 '"version":' "$PROJECT_ROOT/package.json" | sed 's/.*"version": *"\([^"]*\)".*/\1/'
}

# Generate epoch-based 5-digit build number (last 5 digits of epoch minutes)
get_build_number() {
    local epoch_minutes=$(($(date +%s) / 60))
    echo $((epoch_minutes % 100000))
}

# Get full version string (e.g., 2.7.0-12345)
get_full_version() {
    echo "$(get_version)-$(get_build_number)"
}

# Export for use in other scripts
export APP_VERSION=$(get_version)
export BUILD_NUMBER=$(get_build_number)
export FULL_VERSION=$(get_full_version)
export COPYRIGHT="Copyright (C) 2025 Robin L. M. Cheung, MBA. All rights reserved."

# Display version info when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=============================================="
    echo "SwiftChat v${APP_VERSION}"
    echo "${COPYRIGHT}"
    echo "=============================================="
    echo "Version:      ${APP_VERSION}"
    echo "Build Number: ${BUILD_NUMBER}"
    echo "Full Version: ${FULL_VERSION}"
    echo "=============================================="
fi
