#!/bin/bash
# Install all Arm migration tools on the target system
# Supports both local installation (with tarball) and remote installation (via curl)
set -e

# Check architecture
ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64)
    ARCH_NORM="arm64"
    ;;
  x86_64|amd64)
    ARCH_NORM="x86_64"
    ;;
  *)
    echo "[ERROR] Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

INSTALL_PREFIX="/opt/arm-migration-tools"
GITHUB_REPO="arm/arm-migration-tools"

# Improved remote installation detection
REMOTE_INSTALL=false
SCRIPT_DIR="$(dirname "$0")"

# Check if we're running from a pipe (curl | sh) or if no local files exist
if [ "$SCRIPT_DIR" = "/dev/fd" ] || [ "$SCRIPT_DIR" = "/proc/self/fd" ] || [ "$SCRIPT_DIR" = "." ]; then
  REMOTE_INSTALL=true
elif [ ! -f "$SCRIPT_DIR/../README.md" ] && [ -z "$(ls arm-migration-tools-v*.tar.gz 2>/dev/null)" ]; then
  REMOTE_INSTALL=true
fi

# Handle remote installation
if [ "$REMOTE_INSTALL" = true ]; then
  echo "[INFO] Remote installation detected. Downloading latest release..."
  
  # Check for required tools
  if ! command -v curl >/dev/null 2>&1; then
    echo "[ERROR] curl is required for remote installation but not found." >&2
    exit 1
  fi
  
  # Fetch latest release information
  LATEST_RELEASE_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
  echo "[INFO] Fetching latest release information..."
  
  LATEST_TAG=$(curl -s "$LATEST_RELEASE_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | tr -d 'v')
  if [ -z "$LATEST_TAG" ]; then
    echo "[ERROR] Failed to fetch latest release tag" >&2
    exit 1
  fi
  
  VERSION="$LATEST_TAG"
  DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/v$LATEST_TAG/arm-migration-tools-v$LATEST_TAG-$ARCH_NORM.tar.gz"
  echo "[INFO] Downloading version v$LATEST_TAG from $DOWNLOAD_URL..."
  
  # Create temporary directory and download
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  
  if ! curl -L -f -o "arm-migration-tools.tar.gz" "$DOWNLOAD_URL"; then
    echo "[ERROR] Failed to download release tarball" >&2
    exit 1
  fi
  
  # Extract to install prefix
  echo "[INFO] Extracting to $INSTALL_PREFIX..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo tar xzf "arm-migration-tools.tar.gz" -C "$INSTALL_PREFIX"
  
  # Change to the extracted scripts directory
  SCRIPTS_DIR="$INSTALL_PREFIX/scripts"
  
  # Clean up temp directory
  cd /
  rm -rf "$TEMP_DIR"
  
else
  # Handle local installation
  echo "[INFO] Local installation detected."
  
  # Set the version here (default to newest if not set)
  if [ -z "$VERSION" ]; then
    LATEST_TAR=$(ls arm-migration-tools-v*.tar.gz 2>/dev/null | sort -V | tail -n 1)
    if [ -z "$LATEST_TAR" ]; then
      echo "[ERROR] No arm-migration-tools-v*.tar.gz files found." >&2
      exit 1
    fi
    TAR_FILE="$LATEST_TAR"
    VERSION=$(echo "$TAR_FILE" | sed -E 's/.*-v([0-9]+)-.*/\1/')
  else
    TAR_FILE="arm-migration-tools-v$VERSION-$ARCH_NORM.tar.gz"
  fi

  if [ ! -f "$TAR_FILE" ]; then
    echo "[ERROR] $TAR_FILE not found in current directory. Please download it first." >&2
    exit 1
  fi

  echo "[INFO] Extracting $TAR_FILE to $INSTALL_PREFIX..."
  sudo mkdir -p "$INSTALL_PREFIX"
  sudo tar xzf "$TAR_FILE" -C "$INSTALL_PREFIX"
  
  # Use relative path for local installation
  SCRIPTS_DIR="$SCRIPT_DIR"
fi

# Install individual tools
echo "[INFO] Installing individual tools..."

# List of all tools to install
TOOLS=(
  "sysreport"
  "skopeo" 
  "kubearchinspect"
  "perf"
  "mca"
  "aperf"
  "bolt"
  "processwatch"
  "papi"
  "migrate_ease"
  "migrate_ease_wrappers"
  "check_image"
  "porting_advisor"
  "topdown_tool"
)

# Install each tool if its script exists
for tool in "${TOOLS[@]}"; do
  INSTALL_SCRIPT="$SCRIPTS_DIR/install_${tool}.sh"
  if [ -f "$INSTALL_SCRIPT" ]; then
    echo "[INFO] Installing ${tool}..."
    bash "$INSTALL_SCRIPT"
  else
    echo "[WARN] Install script not found: $INSTALL_SCRIPT"
  fi
done

# Install arm-migration-tools-test.sh to /usr/local/bin (for remote installs)
if [ "$REMOTE_INSTALL" = true ] && [ -f "$INSTALL_PREFIX/scripts/arm-migration-tools-test.sh" ]; then
    sudo cp "$INSTALL_PREFIX/scripts/arm-migration-tools-test.sh" /usr/local/bin/arm-migration-tools-test.sh
    sudo chmod +x /usr/local/bin/arm-migration-tools-test.sh
fi

# Set up Python venv and install requirements
VENV_PATH="$INSTALL_PREFIX/venv"
PYTHON3=$(command -v python3)
if [ -z "$PYTHON3" ]; then
  echo "[ERROR] python3 not found. Please install Python 3."
  exit 1
fi
if [ ! -d "$VENV_PATH" ]; then
  echo "[INFO] Creating Python venv at $VENV_PATH..."
  sudo "$PYTHON3" -m venv "$VENV_PATH"
fi
# Upgrade pip and install requirements
sudo "$VENV_PATH/bin/pip" install --upgrade pip
if [ -f "$INSTALL_PREFIX/requirements.txt" ]; then
  sudo "$VENV_PATH/bin/pip" install -r "$INSTALL_PREFIX/requirements.txt"
fi

# Install Topdown Tool in editable mode in the venv
if [ -d "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool" ]; then
  sudo "$VENV_PATH/bin/pip" install -e "$INSTALL_PREFIX/telemetry-solution/tools/topdown_tool"
fi

# Record tool versions in a single file (after install)
VERSIONS_FILE="$INSTALL_PREFIX/tool-versions.txt"
echo "Sysreport: $VERSION" | sudo tee "$VERSIONS_FILE" > /dev/null
echo "Check Image: $VERSION" | sudo tee -a "$VERSIONS_FILE" > /dev/null
if command -v skopeo >/dev/null 2>&1; then
  skopeo --version 2>&1 | head -n1 | awk '{print "Skopeo: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if [ -x "$INSTALL_PREFIX/kubearchinspect/kubearchinspect" ]; then
  "$INSTALL_PREFIX/kubearchinspect/kubearchinspect" version 2>&1 | awk '{print "KubeArchInspect: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if command -v perf >/dev/null 2>&1; then
  perf version 2>&1 | awk '{print "Perf: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
if command -v llvm-mca >/dev/null 2>&1; then
  llvm-mca --version 2>&1 | head -n1 | awk '{print "llvm-mca: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Aperf version
if command -v aperf >/dev/null 2>&1; then
  aperf --version 2>&1 | head -n1 | awk '{print "Aperf: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record BOLT version
if command -v llvm-bolt >/dev/null 2>&1; then
  llvm-bolt --version 2>&1 | head -n2 | awk '{print "BOLT: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Porting Advisor version
if command -v porting-advisor >/dev/null 2>&1; then
  porting-advisor --version 2>&1 | head -n1 | awk '{print "Porting Advisor: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi
# Record Process Watch version
if command -v processwatch >/dev/null 2>&1; then
  processwatch -v 2>&1 | head -n1 | awk '{print "Process Watch: "$0}' | sudo tee -a "$VERSIONS_FILE" > /dev/null
fi

# Remove individual version files if they exist
sudo rm -f "$INSTALL_PREFIX/sysreport.version" "$INSTALL_PREFIX/skopeo.version"

echo "[INFO] Installation process complete."
echo
cat <<EOM
[INFO] To use Python-based Arm Migration Tools interactively, activate the Python virtual environment:
  source /opt/arm-migration-tools/venv/bin/activate
Or use the provided wrappers in /usr/local/bin for each tool (recommended).
EOM
