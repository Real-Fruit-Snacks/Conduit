# Conduit Installation Guide

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Real-Fruit-Snacks/Conduit.git
cd Conduit
```

### 2. Build

```bash
# Build all components
make

# Or build individually
make conduit        # Build Conduit binary only
make socat          # Build stealth SOCAT only
make process-masq   # Build process-masq wrapper only
```

### 3. Test

```bash
make test

# Or test manually
./conduit --help
./conduit --list-masq
```

### 4. Install (Optional)

```bash
# Install to /usr/local/bin (requires sudo)
sudo make install

# Or install to custom location
sudo make install PREFIX=/opt/conduit
```

## Build Requirements

### Required
- GCC or compatible C compiler
- GNU Make
- Standard C library (glibc or musl)

### Optional (for stealth SOCAT)
- OpenSSL development libraries (`libssl-dev` on Debian/Ubuntu)
- GNU readline development libraries (`libreadline-dev`)
- TCP wrappers (`libwrap0-dev`)

### Installing Dependencies

**Debian/Ubuntu:**
```bash
sudo apt-get install build-essential libssl-dev libreadline-dev libwrap0-dev
```

**RHEL/CentOS/Fedora:**
```bash
sudo dnf install gcc make openssl-devel readline-devel tcp_wrappers-devel
```

**Alpine Linux:**
```bash
apk add gcc make musl-dev openssl-dev readline-dev
```

**macOS:**
```bash
brew install gcc make openssl readline
```

## Build Options

### Debug Build
```bash
make CFLAGS="-Wall -g -O0"
```

### Optimized Build
```bash
make CFLAGS="-Wall -O3 -march=native"
```

### Static Build (Portable)
```bash
cd socat-repo
./configure LDFLAGS="-static"
make
```

## Installation Paths

Default installation locations (PREFIX=/usr/local):
- `/usr/local/bin/conduit` - Conduit binary
- `/usr/local/bin/process-masq` - Process masquerading wrapper
- `/usr/local/bin/socat-stealth` - Stealth SOCAT binary

Custom installation:
```bash
# Install to home directory
make install PREFIX=$HOME/.local

# Install to /opt
sudo make install PREFIX=/opt
```

## Uninstall

```bash
sudo make uninstall

# Or with custom prefix
sudo make uninstall PREFIX=/opt/conduit
```

## Verification

After installation, verify Conduit is working:

```bash
conduit --help
conduit --list-masq

# Test basic relay
conduit TCP-LISTEN:8080,fork TCP:example.com:80
```

## Troubleshooting

### Build Errors

**Error: `prctl.h: No such file or directory`**
- Solution: You're on a non-Linux system. The code will fall back to generic implementation.

**Error: `openssl/ssl.h: No such file or directory`**
- Solution: Install OpenSSL development libraries or configure without SSL:
  ```bash
  cd socat-repo && ./configure --disable-openssl
  ```

**Error: Permission denied during `make install`**
- Solution: Use `sudo make install` or install to a user-writable location.

### Runtime Issues

**Error: `Failed to execute stealth socat`**
- Solution: Ensure stealth SOCAT is built:
  ```bash
  make socat
  ```

**Conduit not hiding arguments**
- Solution: The argument hiding happens in the stealth SOCAT binary, not the wrapper. Ensure you've built the modified SOCAT in `socat-repo/`.

## Platform-Specific Notes

### Linux
- Full support for all features
- Uses `prctl()` for process name manipulation
- Tested on: Ubuntu, Debian, RHEL, Alpine

### BSD/macOS
- Uses `setproctitle()` for process name manipulation
- May require different compiler flags
- Tested on: FreeBSD, OpenBSD, macOS

### Windows/Cygwin
- Limited support via Cygwin environment
- Process masquerading may not work reliably
- Consider using WSL2 instead

## Next Steps

After installation, see:
- [README.md](README.md) - Full documentation
- [LICENSE](LICENSE) - License information
- Examples in the README for usage scenarios

## Getting Help

- Issues: https://github.com/Real-Fruit-Snacks/Conduit/issues
- Original SOCAT docs: `socat-repo/doc/socat.html`
