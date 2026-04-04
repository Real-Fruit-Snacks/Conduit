# Changelog

All notable changes to Conduit will be documented in this file.

## [1.0.0] - 2026-04-03

### Project Rebrand
- **Project renamed from "Stealth SOCAT" to "Conduit"**
- Fits water-themed naming convention (Real-Fruit-Snacks portfolio)
- All documentation and code updated to reflect new name

### Added
- Initial release based on SOCAT 1.7.3.3
- Process masquerading capabilities
  - Masquerade as kernel workers (`--masq-kernel`)
  - Masquerade as systemd services (`--masq-systemd`)
  - Masquerade as SSH daemon (`--masq-ssh`)
  - Random process masquerading (`--masq-random`)
  - Custom process names (`--masq '<name>'`)
- Automatic argument hiding from process inspection tools
- Platform support:
  - Linux (prctl-based implementation)
  - BSD (setproctitle-based implementation)
  - Generic fallback for other platforms
- Three deployment options:
  - Standalone stealth library integrated in SOCAT
  - Process masquerading wrapper (`process-masq`)
  - Unified Conduit binary with built-in options
- Complete documentation:
  - README.md with usage examples
  - INSTALL.md with build instructions
  - LICENSE with proper GPLv2 + OpenSSL exception
- Build system:
  - Makefile with multiple targets
  - Support for clean, install, uninstall, test
  - Configurable installation prefix
- .gitignore for common build artifacts

### Files Added
- `conduit.c` - Main Conduit binary (renamed from socat-ultimate.c)
- `socat-repo/stealth.c` - Argument hiding implementation
- `socat-repo/stealth.h` - Stealth function declarations
- `process-masq.c` - Process masquerading wrapper
- `Makefile` - Build system
- `INSTALL.md` - Installation guide
- `CHANGELOG.md` - This file
- `.gitignore` - Git ignore rules

### Modified
- `socat-repo/socat.c` - Integrated stealth_hide_arguments() call
- `LICENSE` - Added OpenSSL exception and copyright notices
- `README.md` - Complete project documentation with Conduit branding
- Documentation in `docs/superpowers/` - Updated to use Conduit name

### License
- Licensed under GNU General Public License v2 (GPLv2)
- Includes OpenSSL linking exception
- Copyright (C) 2026 Real-Fruit-Snacks (modifications)
- Copyright (C) 2001-2023 Gerhard Rieger and contributors (SOCAT base)

### Security Notice
- Designed for authorized security testing only
- Requires explicit written authorization
- Not for malicious or unauthorized use
- User is solely responsible for legal compliance

---

## Version Format

This project uses [Semantic Versioning](https://semver.org/):
- MAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

## Links

- Repository: https://github.com/Real-Fruit-Snacks/Conduit
- Original SOCAT: http://www.dest-unreach.org/socat/
- License: [LICENSE](LICENSE)
