#!/bin/bash
# Build all Arm migration tools and package them for distribution

# Versioning: pass as first argument, default to 1
VERSION="${1:-1}"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        ARCH_NAME="x86_64"
        ;;
    aarch64|arm64)
        ARCH_NAME="arm64"
        ;;
    *)
        echo "[ERROR] Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "[INFO] Building for architecture: $ARCH_NAME"

# Set package root for staging files (default to current directory)
PACKAGE_ROOT="$(pwd)"

echo "[INFO] Starting build process for all tools..."
# Build each tool
bash "$(dirname "$0")/build_sysreport.sh"
bash "$(dirname "$0")/build_skopeo.sh"
bash "$(dirname "$0")/build_kubearchinspect.sh"
bash "$(dirname "$0")/build_perf.sh"
bash "$(dirname "$0")/build_mca.sh"
bash "$(dirname "$0")/build_aperf.sh"
bash "$(dirname "$0")/build_bolt.sh"
bash "$(dirname "$0")/build_porting_advisor.sh"
bash "$(dirname "$0")/build_processwatch.sh"
bash "$(dirname "$0")/build_topdown_tool.sh"
bash "$(dirname "$0")/build_papi.sh"
bash "$(dirname "$0")/build_migrate_ease.sh"

echo "[INFO] Build process complete."

# Package all built tools into a single tarball
PACKAGE_NAME="arm-migration-tools-v$VERSION-$ARCH_NAME.tar.gz"
PACKAGE_CONTENTS="sysreport kubearchinspect aperf bolt-tools porting-advisor-for-graviton requirements.txt processwatch/processwatch telemetry-solution/tools/topdown_tool src/check-image.py scripts papi-install migrate-ease" # Include entire scripts directory

echo "[INFO] Creating $PACKAGE_NAME with: $PACKAGE_CONTENTS"
tar czf "$PACKAGE_NAME" $PACKAGE_CONTENTS

echo "[INFO] All tools packaged into $PACKAGE_NAME."
