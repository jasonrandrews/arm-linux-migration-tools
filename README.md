# Arm Linux Migration Tools

A comprehensive package of migration tools specifically designed to help developers migrate applications and workloads to Arm servers. This package provides a unified installation of 13 essential tools for analyzing, optimizing, and migrating software to Arm architecture.

## Overview

The Arm Linux Migration Tools package simplifies the process of migrating applications to Arm-based systems by providing pre-configured, ready-to-use tools in a single installation. All tools are optimized for Arm Linux systems and include proper dependency management through automated scripts.

## System Requirements

- **Architecture**: Arm (aarch64)
- **Operating System**: Linux (Ubuntu 22.04/24.04 recommended), Amazon Linux 2023, macOS users can test inside Colima/Docker (limitations). 
    - Note (macOS/Colima): perf relies on Linux kernel PMU support and is not supported on macOS/Colima (XNU kernel). The test script will mark it as SKIPPED in these environments.

- **Dependencies**: 
  - Docker/Podman (required for migrate-ease-docker)

## Installation 

You can install the tools using a single command or download the tar file and run in the install script. Pick either alternative. 

### Single line installation

Install directly from the latest GitHub release:

```bash
curl -sSL https://raw.githubusercontent.com/arm/arm-linux-migration-tools/main/scripts/install.sh | sudo bash
```

### Download and install

Download the release tarball and install on your computer:

```bash
# Download the latest release (replace ARCH with arm64 or x86_64)
wget https://github.com/arm/arm-linux-migration-tools/releases/latest/download/arm-migration-tools-v1-arm64.tar.gz

# Extract and install
tar xzf arm-migration-tools-v1-arm64.tar.gz
sudo ./scripts/install.sh
```

### Uninstall

You can uninstall by running:

```bash
/opt/arm-migration-tools/scripts/uninstall.sh
```

**Note** 
The uninstall script:
- Removes `/opt/arm-migration-tools`  
- Removes wrappers in `/usr/local/bin`  
- Removes system packages (perf, llvm-mca, skopeo) where installed  

### Build from Source

To build all tools from source:

```bash
git clone https://github.com/arm/arm-linux-migration-tools.git
cd arm-linux-migration-tools
./scripts/build.sh 
```

The `build.sh` script will:
- Build all tools from source where required
- Download and configure package-manager tools
- Create Python virtual environments for Python-based tools
- Package everything into a distributable tarball (`arm-migration-tools-v[version]-[arch].tar.gz`)
- The default version is 1 but you can pass an integer to `./build.sh` to set a new version number.
- Architecture (arm64 or x86_64) is automatically detected from the build system.

When the build is complete install the tools using:

```bash
./scripts/install.sh
```

**Note:** Both install and uninstall scripts can be run multiple times.
- Running `install.sh` again will detect already-installed tools and skip re-installation.  
- Running `uninstall.sh` again will simply confirm that everything is already removed.

## Tool Notes

- **Skopeo**:  
  - On Ubuntu, installed natively via `apt`.  
  - On Amazon Linux 2023, Skopeo is **not available in default repos**.  
    - You can run it via the provided **container wrapper** (`skopeo-container`)  
    - Or build it manually from source / use GitHub release binaries.  

- **Migrate-Ease**:
  - Five language wrappers (cpp,python,go,js,java) always install.
  - The Docker wrapper installs only if Docker/Podman is detected.
  - On systems without a container runtime, migrate-ease-docker is skipped.
  
  - **CLI vs upstream (Migrate-Ease)**:

  The upstream [migrate-ease](https://github.com/migrate-ease/migrate-ease) README shows usage as:
    ```bash 
    python3 -m {scanner_name} --march {arch} {scan_path}
    ```

    In this package we provide unified wrappers (`migrate-ease-cpp`, `migrate-ease-python`, etc.) in `/usr/local/bin`.
    This ensures consistent CLI names across all supported languages and avoids requiring users to `cd` into the
    package or call `python3 -m` directly. 

    The upstream docs use:

    ```bash 
    python3 -m {scanner_name} --march {arch} {scan_path}
      # e.g. python3 -m cpp --march armv8-a ./myproject
    ```
    This package installs unified wrappers to /usr/local/bin:
    ```bash
    migrate-ease-cpp --march armv8-a ./myproject
    migrate-ease-python --march armv8-a ./myproject
    migrate-ease-go --march armv8-a ./myproject
    migrate-ease-js --march armv8-a ./myproject
    migrate-ease-java --march armv8-a ./myproject
    ```

  Why: consistent command names across languages, no python3 -m …, and wrappers auto-use the venv.


- **Perf**
  - On cloud VMs (AWS,GCP,Azure) with Ubuntu/Amazon Linux, perf installs normally with kernel-matching packages.
  - On macOS Colima or other Docker-on-mac setups, perf will show as SKIPPED in the test script because the underlying XNU kernel doesn't support Linux perf.
  - The test script will report Perf: SKIP (binary present but counters unsupported on this kernel) when running inside mac/Colima or similarly restricted kernels


- **Porting Advisor**:  
  - Installs successfully on both Ubuntu and Amazon Linux.  
  - Requires **Python ≥3.10** to run.  
  - Ubuntu 22.04/24.04 meet this requirement.  
  - Amazon Linux 2023 defaults to Python 3.9 → binary installs but won’t run unless Python is upgraded.



This package includes 13 essential migration and analysis tools:

### 1. **Sysreport** - System Analysis and Reporting
- **Purpose**: System analysis and reporting tool for performance and configuration checks
- **Test Command**: `sysreport --help`
- **Learning Path**: [Get ready for performance analysis with Sysreport](https://learn.arm.com/learning-paths/servers-and-cloud-computing/sysreport/)

### 2. **Skopeo** - Container Image Inspection
- **Purpose**: Container image inspection and manipulation tool
- **Test Command**: `skopeo --help`
- **Install Guide**: [Skopeo install guide](https://learn.arm.com/install-guides/skopeo/)

### 3. **MCA (llvm-mca)** - Machine Code Analyzer
- **Purpose**: Machine Code Analyzer for performance analysis of compiled code
- **Test Command**: `llvm-mca --help`
- **Learning Path**: [Learn about LLVM Machine Code Analyzer](https://learn.arm.com/learning-paths/cross-platform/mca-godbolt/)

### 4. **Topdown Tool** - Performance Analysis
- **Purpose**: Performance analysis methodology tool for Linux systems
- **Test Command**: `topdown-tool --help`
- **Install Guide**: [Telemetry Solution](https://learn.arm.com/install-guides/topdown-tool/)

### 5. **KubeArchInspect** - Kubernetes Architecture Inspection
- **Purpose**: Kubernetes architecture inspection and reporting tool
- **Test Command**: `kubearchinspect --help`
- **Learning Path**: [Migrate containers to Arm using KubeArchInspect](https://learn.arm.com/learning-paths/servers-and-cloud-computing/kubearchinspect/)

### 6. **Migrate Ease** - Migration Assistance
- **Purpose**: Migration assistance tool for analyzing and porting workloads
- **Test Command**: `migrate-ease-cpp --help`
- **Learning Path**: [Migrate applications to Arm servers using migrate-ease](https://learn.arm.com/learning-paths/servers-and-cloud-computing/migrate-ease/)

### 7. **Aperf** - Performance Monitoring
- **Purpose**: Performance monitoring tool for Linux systems
- **Test Command**: `aperf --help`
- **Install Guide**: [Aperf install guide](https://learn.arm.com/install-guides/aperf/)

### 8. **BOLT** - Binary Optimization
- **Purpose**: Binary optimization and layout tool (part of LLVM)
- **Test Commands**: 
  - `llvm-bolt --help`
  - `perf2bolt --help`
- **Install Guide**: [BOLT install guide](https://learn.arm.com/install-guides/bolt/)

### 9. **PAPI** - Performance API
- **Purpose**: Performance API for accessing hardware performance counters
- **Test Command**: `papi_avail -h`
- **Install Guide**: [PAPI install guide](https://learn.arm.com/install-guides/papi/)

### 10. **Perf** - Linux Performance Analysis
- **Purpose**: Linux performance analysis tool for profiling and tracing
- **Test Command**: `perf --help`
- **Install Guide**: [Perf install guide](https://learn.arm.com/install-guides/perf/)

### 11. **Process Watch** - Process Monitoring
- **Purpose**: Process monitoring tool for Linux systems
- **Test Command**: `processwatch -h`
- **Learning Path**: [Run Process watch on your Arm machine](https://learn.arm.com/learning-paths/servers-and-cloud-computing/processwatch/)

### 12. **Check Image** - Container Arm Support Checker
- **Purpose**: Checks a container image for Arm architecture support
- **Test Command**: `check-image -h`
- **Learning Path**: [Check Image on learn.arm.com](https://learn.arm.com/learning-paths/cross-platform/docker/check-images/)

### 13. **Porting Advisor** - Software Portability Assessment
- **Purpose**: Tool to assess portability of software to Arm architecture
- **Test Command**: `porting-advisor --help`
- **Install Guide**: [Porting Advisor install guide](https://learn.arm.com/install-guides/porting-advisor/)

## Testing Installation

After installation, verify all tools are working correctly:

```bash
arm-migration-tools-test.sh
```

This script writes:
  - arm-migration-tools-test.log - full human readable output
  - arm-migration-tools-test.summary.tsv – a 3-column summary: tool / status / note

Statuses:
	•	PASS – tool is present and the smoke test succeeded
	•	SKIP – intentionally not tested on this system (e.g., perf on mac/Colima; migrate-ease-docker without Docker/Podman)
	•	FAIL – tool found but the smoke test failed (check the log for details)


### Individual Tool Testing

You can also test individual tools using their respective help commands:

```bash
# System analysis
sysreport --help

# Container tools
skopeo --help
check-image -h

# Performance analysis
llvm-mca --help
topdown-tool --help
aperf --help
perf --help
papi_avail -h
processwatch -h

# Migration tools
kubearchinspect --help
migrate-ease-cpp --help
porting-advisor --help

# Binary optimization
llvm-bolt --help
perf2bolt --help
```

## Architecture

### Installation Structure

All tools are installed to `/opt/arm-migration-tools/` with the following structure:

```
/opt/arm-migration-tools/
├── venv/                    # Python virtual environment
├── scripts/                 # Installation and management scripts
├── sysreport/              # Sysreport tool
├── kubearchinspect/        # KubeArchInspect tool
├── aperf/                  # Aperf binaries
├── processwatch/           # Process Watch binary
├── src/                    # Source files (check-image.py)
├── requirements.txt        # Python dependencies
└── tool-versions.txt       # Installed tool versions
```

### Python Virtual Environment

Python-based tools use a shared virtual environment at `/opt/arm-migration-tools/venv/`. You can activate it manually:

```bash
source /opt/arm-migration-tools/venv/bin/activate
```

However, wrapper scripts in `/usr/local/bin/` are provided for convenient access to all Python tools.

### Package Management Integration

Tools available through package managers (like `perf`, `llvm-mca`, `skopeo`) are installed system-wide using the appropriate package manager for your distribution.

## Development

### Project Structure

```
arm-linux-migration-tools/
├── scripts/                 # Build, install, and uninstall scripts
│   ├── build.sh            # Main build script
│   ├── install.sh          # Main installation script
│   ├── uninstall.sh        # Main uninstallation script
│   ├── build_*.sh          # Individual tool build scripts
│   ├── install_*.sh        # Individual tool install scripts
│   └── uninstall_*.sh      # Individual tool uninstall scripts
├── src/                    # Source files
│   └── check-image.py      # Container image checker
├── docs/                   # Documentation
└── .github/                # GitHub configuration
```

### Building Individual Tools

Each tool has its own build script in the `scripts/` directory:

```bash
# Build specific tools
./scripts/build_sysreport.sh
./scripts/build_aperf.sh
./scripts/build_processwatch.sh
# ... etc
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on Arm Linux systems
5. Submit a pull request

## Troubleshooting

### Common Issues

**Architecture Check Failed**
- Ensure you're running on an Arm system
- Check with: `uname -m` (should show `aarch64`)

**Python Virtual Environment Issues**
- Ensure Python 3 is installed: `python3 --version`
- Check virtual environment: `ls -la /opt/arm-migration-tools/venv/`

**Tool Not Found After Installation**
- Check if tool is in PATH: `which <tool-name>`
- Try using the full path: `/usr/local/bin/<tool-name>`
- Verify installation: `arm-migration-tools-test.sh`

**Migrate-Ease Python ImportError: failed to find libmagic**  
If you see this error, it means your base OS image is missing the libmagic library.  
Normally `install.sh` installs it automatically, but if running inside a minimal container, you may need to install manually:  
- Ubuntu/Debian: `apt-get update && apt-get install -y file libmagic1`  
- Amazon Linux / RHEL / Fedora: `dnf install -y file-libs || yum install -y file-libs`  

**Permission Errors**
- Installation requires sudo privileges
- Ensure you can run: `sudo ls /opt/`

### Getting Help

- **Documentation**: Visit [learn.arm.com](https://learn.arm.com) for detailed guides
- **Issues**: Report bugs on the [GitHub Issues page](https://github.com/arm/arm-linux-migration-tools/issues)
- **Community**: Join the Arm Developer Community forums

## License

This project is licensed under the MIT License. See individual tool repositories for their specific licenses.

## Links
- **GitHub Repository**: [github.com/arm/arm-linux-migration-tools](https://github.com/arm/arm-linux-migration-tools)
- **Arm Learning Paths**: [learn.arm.com](https://learn.arm.com)
- **Arm Developer Community**: [community.arm.com](https://community.arm.com)
