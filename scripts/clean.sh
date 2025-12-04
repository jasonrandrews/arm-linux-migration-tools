#!/bin/bash
# Clean up build and install artifacts from the project directory
set -e

# Remove cloned tool directories
if [ -d sysreport ]; then
  echo "[INFO] Removing sysreport directory..."
  rm -rf sysreport
fi

# Remove generated tarball
if ls arm-migration-tools*.tar.gz 1> /dev/null 2>&1; then
  echo "[INFO] Removing arm-migration-tools tarballs..."
  rm -f arm-migration-tools*.tar.gz
fi

# Remove KubeArchInspect tarball and directory
if [ -f kubearchinspect_Linux_arm64.tar.gz ]; then
  echo "[INFO] Removing kubearchinspect_Linux_arm64.tar.gz..."
  rm -f kubearchinspect_Linux_arm64.tar.gz
fi
if [ -d kubearchinspect ]; then
  echo "[INFO] Removing kubearchinspect directory..."
  rm -rf kubearchinspect
fi

# Remove any .log files in the project directory
find . -maxdepth 1 -type f -name "*.log" -exec rm -f {} +

# Remove downloaded Aperf tarball and extracted directory
if ls aperf-*-aarch64.tar.gz 1> /dev/null 2>&1; then
  echo "[INFO] Removing downloaded Aperf tarballs..."
  rm -f aperf-*-aarch64.tar.gz
fi
if [ -d aperf-bin ]; then
  echo "[INFO] Removing extracted Aperf directory aperf-bin..."
  rm -rf aperf-bin
fi
if [ -d aperf ]; then
  echo "[INFO] Removing extracted Aperf directory aperf..."
  rm -rf aperf
fi

# Remove downloaded BOLT tarballs and extracted directory
if ls clang+llvm-*-aarch64-linux-gnu.tar.xz 1> /dev/null 2>&1; then
  echo "[INFO] Removing downloaded BOLT tarballs..."
  rm -f clang+llvm-*-aarch64-linux-gnu.tar.xz
fi
if [ -d bolt-bin ]; then
  echo "[INFO] Removing extracted BOLT directory bolt-bin..."
  rm -rf bolt-bin
fi
if [ -d bolt-tools ]; then
  echo "[INFO] Removing bolt-tools directory..."
  rm -rf bolt-tools
fi

# Remove Process Watch source directory if present
if [ -d processwatch ]; then
  echo "[INFO] Removing processwatch source directory..."
  rm -rf processwatch
fi

# Clean all build artifacts
if [ -d build ]; then
  echo "[INFO] Removing build directory..."
  rm -rf build
fi

# Clean Migrate Ease build artifacts
rm -rf migrate-ease

# Remove staged PAPI install directory
if [ -d papi-install ]; then
  echo "[INFO] Removing staged PAPI install directory papi-install..."
  rm -rf papi-install
fi

# Remove Porting Advisor source directory
if [ -d porting-advisor-for-graviton ]; then
  echo "[INFO] Removing porting-advisor-for-graviton directory..."
  rm -rf porting-advisor-for-graviton
fi

# Remove Process Watch binary directory
if [ -d processwatch-bin ]; then
  echo "[INFO] Removing processwatch-bin directory..."
  rm -rf processwatch-bin
fi

# Remove Telemetry Solution (Topdown Tool) source directory
if [ -d telemetry-solution ]; then
  echo "[INFO] Removing telemetry-solution directory..."
  rm -rf telemetry-solution
fi

# Remove generated requirements.txt if present
if [ -f requirements.txt ]; then
  echo "[INFO] Removing generated requirements.txt..."
  rm -f requirements.txt
fi

# Add more cleanup steps for other tools as needed

echo "[INFO] Project directory cleaned."
