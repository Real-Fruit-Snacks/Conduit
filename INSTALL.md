# Conduit Installation Guide

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Real-Fruit-Snacks/Conduit.git
cd Conduit
```

### 2. Build

```bash
# Build the unified binary
make

# The binary will be at: socat-repo/conduit
```

### 3. Test

```bash
make test

# Or test manually
./socat-repo/conduit -h
./socat-repo/conduit -V
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

### Optional (for full features)
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

### Standard Build
```bash
make
```

### Debug Build
```bash
make CFLAGS="-Wall -g -O0"
```

### Optimized Build
```bash
make CFLAGS="-Wall -O3 -march=native"
```

### Static Build (Portable)

For maximum portability, build a static binary that includes all dependencies:

```bash
cd socat-repo
./configure LDFLAGS="-static"
make conduit
```

The resulting static binary can be copied to any system with the same architecture without requiring shared libraries. This is ideal for:
- Deploying to minimal/embedded systems
- Creating portable security tools
- Avoiding dependency issues
- Running in containers without runtime dependencies

**Note:** Static builds are significantly larger (~2-3MB vs ~400KB) but are completely self-contained.

### Cross-Compilation

To build for a different architecture:

```bash
# For ARM64
cd socat-repo
./configure --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc
make conduit

# For 32-bit x86
cd socat-repo
./configure --host=i686-linux-gnu CC=i686-linux-gnu-gcc CFLAGS="-m32"
make conduit
```

## Installation

### Binary Installation

Default installation locations (PREFIX=/usr/local):
- `/usr/local/bin/conduit` - Main binary

Custom installation:
```bash
# Install to home directory
make install PREFIX=$HOME/.local

# Install to /opt
sudo make install PREFIX=/opt
```

### Man Page Installation

```bash
# Install man page
sudo install -m 644 conduit.1 /usr/local/share/man/man1/
sudo mandb  # Update man database

# Test
man conduit
```

### Shell Completion Installation

**Bash:**
```bash
# System-wide
sudo install -m 644 completions/conduit.bash /etc/bash_completion.d/

# User-only
mkdir -p ~/.local/share/bash-completion/completions/
install -m 644 completions/conduit.bash ~/.local/share/bash-completion/completions/conduit
```

**Zsh:**
```bash
# System-wide
sudo install -m 644 completions/_conduit /usr/local/share/zsh/site-functions/

# User-only
mkdir -p ~/.zsh/completions/
install -m 644 completions/_conduit ~/.zsh/completions/
# Add to ~/.zshrc: fpath=(~/.zsh/completions $fpath)
```

### Example Scripts

Example scripts are located in the `examples/` directory:

```bash
# Install examples
sudo mkdir -p /usr/local/share/conduit/examples
sudo install -m 755 examples/*.sh /usr/local/share/conduit/examples/

# Or copy to home directory
mkdir -p ~/.local/share/conduit/examples
cp examples/*.sh ~/.local/share/conduit/examples/
```

## Uninstall

```bash
sudo make uninstall

# Or with custom prefix
sudo make uninstall PREFIX=/opt/conduit

# Remove man page and completions
sudo rm -f /usr/local/share/man/man1/conduit.1
sudo rm -f /etc/bash_completion.d/conduit.bash
sudo rm -f /usr/local/share/zsh/site-functions/_conduit
```

## Verification

After installation, verify Conduit is working:

```bash
# Check version
conduit -V

# View help
conduit -h

# View man page
man conduit

# Test basic relay
conduit -Mk TCP-LISTEN:8080,fork TCP:example.com:80
```

## Troubleshooting

### Build Errors

**Error: `prctl.h: No such file or directory`**
- Solution: You're on a non-Linux system. The code will fall back to BSD `setproctitle()`.

**Error: `openssl/ssl.h: No such file or directory`**
- Solution: Install OpenSSL development libraries or configure without SSL:
  ```bash
  cd socat-repo && ./configure --disable-openssl && make conduit
  ```

**Error: `No rule to make target 'conduit'`**
- Solution: Run `./configure` in the socat-repo directory first:
  ```bash
  cd socat-repo && ./configure && cd .. && make
  ```

**Error: Permission denied during `make install`**
- Solution: Use `sudo make install` or install to a user-writable location.

### Runtime Issues

**Process masquerading not working**
- Solution: Ensure you're running with appropriate permissions. Some systems require CAP_SYS_RESOURCE capability.

**Static binary "not found" error**
- Solution: Statically linked binaries on some systems need the right interpreter. Check with:
  ```bash
  file socat-repo/conduit
  ldd socat-repo/conduit  # Should show "not a dynamic executable"
  ```

**Shell completion not working**
- Solution: Restart your shell or source the completion file:
  ```bash
  # Bash
  source /etc/bash_completion.d/conduit.bash
  
  # Zsh
  autoload -Uz compinit && compinit
  ```

## Platform-Specific Notes

### Linux
- Full support for all features
- Uses `prctl(PR_SET_NAME)` for process name manipulation
- Tested on: Ubuntu 22.04+, Debian 11+, RHEL 8+, Alpine 3.17+

### BSD
- Uses `setproctitle()` for process name manipulation
- May require `gmake` instead of `make`
- Tested on: FreeBSD 13+, OpenBSD 7+

### macOS
- Uses `setproctitle()` for process name manipulation
- May require Homebrew compiler tools
- Tested on: macOS 12+ (Monterey and later)

### Windows/Cygwin
- **Not recommended** - limited support via Cygwin
- Process masquerading may not work reliably
- Consider using WSL2 instead for full Linux compatibility

## Building from Downloaded Release

If you downloaded a release tarball instead of cloning:

```bash
tar -xzf conduit-linux.tar.gz
cd conduit-linux

# The binary is pre-built and ready to use
./conduit -h

# Install it
sudo install -m 755 conduit /usr/local/bin/
```

## Development Build

For development with all debug symbols:

```bash
cd socat-repo
./configure CFLAGS="-g -O0 -Wall -Wextra"
make conduit

# Use gdb
gdb --args ./conduit -Mk TCP-LISTEN:8080 TCP:localhost:80
```

## Next Steps

After installation, see:
- [README.md](README.md) - Full documentation and usage examples
- [LICENSE](LICENSE) - License information (GPLv2 + OpenSSL exception)
- `examples/` directory - Common use case scripts
- `man conduit` - Detailed man page

## Getting Help

- **Issues**: https://github.com/Real-Fruit-Snacks/Conduit/issues
- **Documentation**: https://real-fruit-snacks.github.io/Conduit
- **SOCAT docs**: `socat-repo/doc/socat.html` (base functionality)
