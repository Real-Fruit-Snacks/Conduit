# Conduit

<div align="center">

![License](https://img.shields.io/badge/license-GPLv2-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20BSD%20%7C%20macOS-lightgrey)
![C](https://img.shields.io/badge/language-C-orange)
![SOCAT](https://img.shields.io/badge/based%20on-SOCAT%201.7.3.3-green)

**Network relay with process masquerading for authorized security operations**

A derivative of [SOCAT](http://www.dest-unreach.org/socat/) with built-in stealth capabilities: automatic argument hiding and process masquerading designed for operational security in authorized penetration testing, red team operations, and security research.

[Features](#features) •
[Installation](#installation) •
[Usage](#usage) •
[Architecture](#architecture) •
[Legal Notice](#legal-notice)

</div>

---

## ⚠️ AUTHORIZED USE ONLY

**This tool is designed exclusively for authorized security testing.**

- ✅ Use with explicit written authorization from system owners
- ✅ Authorized penetration testing and red team operations
- ✅ Security research in controlled environments
- ✅ CTF competitions and defensive security training
- ❌ Unauthorized access to computer systems is illegal
- ❌ Not intended for malicious purposes

**User is solely responsible for legal compliance. Unauthorized use may result in criminal prosecution.**

---

## Features

### 🔒 Stealth Capabilities

| Feature | Description |
|---------|-------------|
| **Argument Hiding** | Command-line arguments hidden from \`ps\`, \`top\`, \`htop\`, \`/proc/cmdline\` |
| **Process Masquerading** | Appear as legitimate system processes (kernel workers, system services) |
| **Platform Support** | Linux (prctl), BSD (setproctitle), generic fallback |
| **Zero Configuration** | Stealth features activate automatically |

### 🎭 Masquerading Options

| Preset | Process Name | Use Case |
|--------|--------------|----------|
| \`--masq-kernel\` | \`[kworker/0:1]\` | Kernel worker thread |
| \`--masq-systemd\` | \`systemd-logind\` | System service |
| \`--masq-ssh\` | \`/usr/sbin/sshd\` | SSH daemon |
| \`--masq-random\` | (random) | Random system process |
| \`--masq '<name>'\` | Custom | User-defined name |
| \`--no-masq\` | \`socat\` | Argument hiding only |

### 🌊 Full SOCAT Capabilities

- **Bidirectional relay** between independent data channels
- **Protocol support**: TCP, UDP, SCTP, UNIX sockets, SSL/TLS, SOCKS, HTTP CONNECT
- **Data channels**: Files, pipes, PTYs, raw IP, TUN/TAP interfaces
- **Advanced options**: 100+ configuration parameters for fine-grained control
- **Cross-platform**: Linux, BSD, macOS, Solaris, AIX, HP-UX

### 📦 Deployment Options

\`\`\`
┌─────────────────────────────────────────────────────────┐
│                  Deployment Options                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Stealth SOCAT Binary                               │
│     └─ Modified SOCAT with integrated stealth lib      │
│        • Automatic argument hiding                      │
│        • Full SOCAT compatibility                       │
│                                                         │
│  2. Process Masquerading Wrapper                       │
│     └─ Standalone wrapper for stealth SOCAT            │
│        • Launch with masqueraded process name           │
│        • Random or preset identities                    │
│                                                         │
│  3. Conduit Binary (Recommended)                       │
│     └─ Unified executable with built-in options        │
│        • --masq-* presets for quick deployment         │
│        • Single binary distribution                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
\`\`\`

---

## Installation

### Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| **GCC** | Any | C compiler |
| **GNU Make** | Any | Build system |
| **OpenSSL** | Optional | SSL/TLS support |
| **GNU Readline** | Optional | Interactive features |

### Quick Start

\`\`\`bash
# Clone repository
git clone https://github.com/Real-Fruit-Snacks/Conduit.git
cd Conduit

# Build all components
make

# Test installation
make test
\`\`\`

### Build Individual Components

\`\`\`bash
# Build Conduit binary only
make conduit

# Build stealth SOCAT only
make socat

# Build process-masq wrapper only
make process-masq
\`\`\`

### Platform-Specific Instructions

<details>
<summary><b>Debian/Ubuntu</b></summary>

\`\`\`bash
# Install dependencies
sudo apt-get install build-essential libssl-dev libreadline-dev

# Build
make
\`\`\`
</details>

<details>
<summary><b>RHEL/CentOS/Fedora</b></summary>

\`\`\`bash
# Install dependencies
sudo dnf install gcc make openssl-devel readline-devel

# Build
make
\`\`\`
</details>

<details>
<summary><b>macOS</b></summary>

\`\`\`bash
# Install dependencies (Homebrew)
brew install gcc make openssl readline

# Build
make
\`\`\`
</details>

<details>
<summary><b>FreeBSD/OpenBSD</b></summary>

\`\`\`bash
# Install dependencies (FreeBSD)
pkg install gmake gcc

# Build using GNU Make
gmake
\`\`\`
</details>

### System Installation

\`\`\`bash
# Install to /usr/local/bin (requires sudo)
sudo make install

# Install to custom location
sudo make install PREFIX=/opt/conduit

# Uninstall
sudo make uninstall
\`\`\`

---

## Usage

### Conduit Binary

\`\`\`bash
# Masquerade as kernel worker
./conduit --masq-kernel TCP-LISTEN:8080,fork TCP:10.0.0.5:80

# Masquerade as systemd service
./conduit --masq-systemd UNIX-LISTEN:/tmp/sock TCP:192.168.1.10:22

# Masquerade as SSH daemon
./conduit --masq-ssh TCP-LISTEN:22,reuseaddr TCP:real-ssh-server:22

# Random system process
./conduit --masq-random TCP-LISTEN:443,cert=server.pem TCP:backend:443

# Custom process name
./conduit --masq '[nginx: worker process]' TCP-LISTEN:80 TCP:app:8080

# Argument hiding only (no masquerading)
./conduit --no-masq TCP-LISTEN:3306 TCP:db-server:3306

# List available masquerade options
./conduit --list-masq
\`\`\`

### Process Masquerading Wrapper

\`\`\`bash
# Masquerade as specific process
./process-masq -m 'systemd-resolved' -- TCP-LISTEN:53,fork UDP:8.8.8.8:53

# Use random identity
./process-masq -r -- UNIX-LISTEN:/var/run/control TCP:target:443

# List available options
./process-masq -l
\`\`\`

### Stealth SOCAT (Direct)

\`\`\`bash
# Standard SOCAT usage with automatic argument hiding
cd socat-repo
./socat TCP-LISTEN:8080,reuseaddr,fork TCP:example.com:80

# Check process listing - arguments are hidden
ps aux | grep socat
\`\`\`

### Common Use Cases

<details>
<summary><b>Port Forwarding</b></summary>

\`\`\`bash
# Forward local port 8080 to remote server
./conduit --masq-systemd \\
  TCP-LISTEN:8080,reuseaddr,fork \\
  TCP:remote-server.example.com:80
\`\`\`
</details>

<details>
<summary><b>SSL/TLS Tunnel</b></summary>

\`\`\`bash
# Create encrypted tunnel
./conduit --masq-ssh \\
  TCP-LISTEN:443,reuseaddr,fork,cert=server.pem,verify=0 \\
  TCP:internal-service:8080
\`\`\`
</details>

<details>
<summary><b>UNIX Socket Relay</b></summary>

\`\`\`bash
# Bridge UNIX socket to TCP
./conduit --masq-kernel \\
  UNIX-LISTEN:/tmp/control.sock,fork \\
  TCP:192.168.1.100:9000
\`\`\`
</details>

<details>
<summary><b>SOCKS Proxy</b></summary>

\`\`\`bash
# SOCKS proxy with masquerading
./conduit --masq '[kworker/u8:0]' \\
  TCP-LISTEN:1080,reuseaddr,fork \\
  SOCKS4A:proxy-server:google.com:80,socksport=1080
\`\`\`
</details>

---

## Architecture

### Component Overview

\`\`\`
┌─────────────────────────────────────────────────────────────────┐
│                         Conduit System                          │
└─────────────────────────────────────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                │                               │
        ┌───────▼───────┐               ┌──────▼──────┐
        │  Conduit CLI  │               │ process-masq │
        │   (conduit)   │               │   wrapper    │
        └───────┬───────┘               └──────┬───────┘
                │                               │
                │  argv manipulation            │  execv() with
                │  + masquerade preset          │  masqueraded argv[0]
                │                               │
                └───────────────┬───────────────┘
                                │
                        ┌───────▼────────┐
                        │  Stealth SOCAT │
                        │  (socat-repo/) │
                        └────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
        ┌───────▼──────┐ ┌─────▼──────┐ ┌─────▼──────┐
        │  stealth.c   │ │  socat.c   │ │  xio-*.c   │
        │ Arg Hiding   │ │ Main Logic │ │  I/O Ops   │
        └──────────────┘ └────────────┘ └────────────┘
                │
        ┌───────┴────────────────────┐
        │                            │
    ┌───▼────┐    ┌──────────┐  ┌───▼────────┐
    │ prctl  │    │setproctitle│ │argv[] clear│
    │(Linux) │    │ (BSD/macOS)│ │ (generic)  │
    └────────┘    └────────────┘ └────────────┘
\`\`\`

### How Argument Hiding Works

\`\`\`c
// After argument parsing in main():
stealth_hide_arguments(argc, argv);

Platform Detection:
├─ Linux   → prctl(PR_SET_NAME) + argv[] overwrite
├─ BSD     → setproctitle() + argv[] clearing  
└─ Generic → Manual argv[] memory zeroing
\`\`\`

### Process Masquerading Flow

\`\`\`
1. User invokes: ./conduit --masq-kernel TCP-LISTEN:80 ...
                     │
2. Conduit parses masquerade option
                     │
3. Sets argv[0] = "[kworker/0:1]"
                     │
4. Executes: execv("socat-repo/socat", modified_argv)
                     │
5. Stealth SOCAT launches with masqueraded name
                     │
6. stealth_hide_arguments() called in main()
                     │
7. Result: Process appears as "[kworker/0:1]" with no args
\`\`\`

---

## Project Structure

\`\`\`
Conduit/
├── conduit.c                    # Main Conduit binary (unified interface)
├── conduit                      # Compiled binary
├── process-masq.c               # Process masquerading wrapper
├── Makefile                     # Build system
│
├── README.md                    # This file
├── LICENSE                      # GPLv2 with OpenSSL exception
├── INSTALL.md                   # Installation guide
├── CHANGELOG.md                 # Version history
├── SECURITY.md                  # Security policy
├── CONTRIBUTING.md              # Contribution guidelines
│
├── socat-repo/                  # Modified SOCAT 1.7.3.3
│   ├── stealth.c               # Argument hiding implementation
│   ├── stealth.h               # Stealth function declarations
│   ├── socat.c                 # Main program (modified for stealth)
│   │
│   ├── xio-*.c                 # I/O subsystems (50+ modules)
│   ├── error.c, sysutils.c     # Support libraries
│   ├── configure               # Autoconf build configuration
│   └── doc/                    # Original SOCAT documentation
│
├── docs/                        # GitHub Pages site
│   └── index.html              # Project website
│
└── .github/
    └── workflows/
        └── ci.yml              # CI/CD pipeline
\`\`\`

---

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Language** | C (C99) | Low-level system programming |
| **Base** | [SOCAT 1.7.3.3](http://www.dest-unreach.org/socat/) | Network relay foundation |
| **Build System** | GNU Make + Autoconf | Cross-platform compilation |
| **Platform APIs** | prctl, setproctitle | Process manipulation |
| **SSL/TLS** | OpenSSL | Encrypted communications |
| **Readline** | GNU Readline | Interactive features |

---

## Command Reference

### Conduit Options

| Option | Description |
|--------|-------------|
| \`--masq <name>\` | Masquerade as specific process name |
| \`--masq-kernel\` | Preset: kernel worker thread |
| \`--masq-systemd\` | Preset: systemd service |
| \`--masq-ssh\` | Preset: SSH daemon |
| \`--masq-random\` | Preset: random system process |
| \`--list-masq\` | Show available masquerade options |
| \`--no-masq\` | Use argument hiding only |
| \`--help\` | Display help message |

### SOCAT Address Types (Examples)

| Type | Syntax | Example |
|------|--------|---------|
| TCP | \`TCP:<host>:<port>\` | \`TCP:example.com:80\` |
| TCP Listen | \`TCP-LISTEN:<port>\` | \`TCP-LISTEN:8080,fork\` |
| UDP | \`UDP:<host>:<port>\` | \`UDP:8.8.8.8:53\` |
| UNIX | \`UNIX-CONNECT:<path>\` | \`UNIX-CONNECT:/var/run/sock\` |
| UNIX Listen | \`UNIX-LISTEN:<path>\` | \`UNIX-LISTEN:/tmp/control.sock\` |
| SSL | \`OPENSSL:<host>:<port>\` | \`OPENSSL:server:443,verify=0\` |
| File | \`FILE:<path>\` | \`FILE:/var/log/output.log,create\` |
| SOCKS | \`SOCKS4A:<proxy>:<target>:<port>\` | \`SOCKS4A:proxy:target:80\` |

*See \`socat-repo/doc/socat.html\` for complete address reference (50+ types).*

---

## Platform Support

| Platform | Argument Hiding | Process Masquerading | Status |
|----------|----------------|---------------------|--------|
| **Linux** | ✅ prctl | ✅ Full support | Tested |
| **FreeBSD** | ✅ setproctitle | ✅ Full support | Tested |
| **OpenBSD** | ✅ setproctitle | ✅ Full support | Tested |
| **macOS** | ✅ setproctitle | ⚠️ Limited | Tested |
| **Solaris** | ⚠️ Generic fallback | ⚠️ Limited | Untested |
| **AIX** | ⚠️ Generic fallback | ⚠️ Limited | Untested |

**Legend:**
- ✅ Full support with platform-specific APIs
- ⚠️ Generic fallback (may be visible to advanced inspection)

---

## Detection Considerations

While Conduit hides process information from basic inspection tools:

| Monitoring Method | Detection Risk |
|------------------|----------------|
| \`ps\`, \`top\`, \`htop\` | ✅ Hidden |
| \`/proc/<pid>/cmdline\` | ✅ Hidden |
| \`/proc/<pid>/environ\` | ⚠️ Visible |
| System call tracing (\`strace\`, \`dtrace\`) | 🔴 Visible |
| Network monitoring | 🔴 Visible |
| Kernel security modules (SELinux, AppArmor) | 🔴 May detect |
| EDR/XDR solutions | 🔴 May flag |
| Forensic memory analysis | 🔴 Recoverable |

**Use within authorized scope and understand monitoring capabilities of target environment.**

---

## Development

### Building for Development

\`\`\`bash
# Debug build with symbols
make CFLAGS="-Wall -g -O0"

# Optimized build
make CFLAGS="-Wall -O3 -march=native"

# Clean build artifacts
make clean
\`\`\`

### Running Tests

\`\`\`bash
# Basic functionality tests
make test

# Test specific component
./conduit --help
./conduit --list-masq
\`\`\`

### Code Style

- **Language**: C99 standard
- **Indentation**: Matches SOCAT style (mix of tabs/spaces)
- **Comments**: Inline for complex logic
- **Error handling**: Perror for system calls

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Areas of interest:**
- Additional platform support (Windows/Cygwin, Android)
- Enhanced masquerading presets
- Improved stealth techniques
- Bug fixes and testing
- Documentation improvements

**Requirements:**
- Maintain GPLv2 licensing
- Include appropriate copyright notices
- Test on target platforms
- Update documentation

---

## Legal Notice

### License

This project is licensed under the **GNU General Public License version 2** (GPLv2) with OpenSSL linking exception, as required by SOCAT's license.

**Copyright:**
- **Conduit modifications**: Copyright © 2026 Real-Fruit-Snacks
- **Original SOCAT**: Copyright © 2001-2023 Gerhard Rieger and contributors

See [LICENSE](LICENSE) for complete terms.

### Authorized Use Only

⚠️ **This tool is intended for authorized security testing only.**

- Unauthorized access to computer systems is **illegal** in most jurisdictions
- User is **solely responsible** for compliance with applicable laws
- Intended for professional security practitioners, researchers, and educators
- Not intended for malicious purposes or unauthorized access
- Misuse may result in **criminal prosecution**

**By using this software, you agree to use it only with explicit written authorization from system owners.**

### Disclaimer

\`\`\`
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
THE AUTHORS ARE NOT LIABLE FOR ANY DAMAGES ARISING FROM USE.
USE AT YOUR OWN RISK. SEE LICENSE FOR DETAILS.
\`\`\`

---

## Resources

- **Original SOCAT**: http://www.dest-unreach.org/socat/
- **Documentation**: \`socat-repo/doc/socat.html\`
- **Examples**: \`socat-repo/EXAMPLES\`
- **Security**: See [SECURITY.md](SECURITY.md)
- **Issues**: https://github.com/Real-Fruit-Snacks/Conduit/issues

---

## Acknowledgments

- **Gerhard Rieger** and SOCAT contributors for the foundational relay tool
- The security research and red team communities
- All contributors to this project

---

<div align="center">

**Part of the [Real-Fruit-Snacks](https://github.com/Real-Fruit-Snacks) water-themed security toolkit** 🌊

*Tidepool • Riptide • Cascade • Slipstream • HydroShot • **Conduit***

**Remember: With great power comes great responsibility.**

</div>
