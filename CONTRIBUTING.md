# Contributing to Conduit

Thank you for your interest in contributing to Conduit! This document provides guidelines for contributing to this project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Legal Requirements](#legal-requirements)

---

## Code of Conduct

### Our Standards

This project maintains high standards for:
- **Ethical conduct**: Contributions must support authorized security testing
- **Technical excellence**: Code must be secure, well-tested, and documented
- **Legal compliance**: All contributions must comply with applicable laws
- **Respectful collaboration**: Treat all contributors with respect

### Prohibited Contributions

We will **not accept**:
- Features designed for unauthorized access or malicious use
- Contributions that violate laws or regulations
- Code that evades detection in unauthorized contexts
- Malicious backdoors or vulnerabilities
- Stolen or improperly licensed code

---

## Getting Started

### Areas for Contribution

We welcome contributions in the following areas:

**Code Contributions:**
- 🐛 Bug fixes in stealth functionality
- ✨ New platform support (Windows/Cygwin, Android, etc.)
- 🎭 Additional masquerading presets
- ⚡ Performance optimizations
- 🔒 Security improvements

**Documentation:**
- 📖 Usage examples and tutorials
- 🌍 Platform-specific installation guides
- 🔍 Technical architecture documentation
- 🎓 Educational materials for authorized testing

**Testing:**
- 🧪 Unit tests for stealth functionality
- 🔬 Platform compatibility testing
- 📊 Performance benchmarks
- 🛡️ Security testing and review

**Infrastructure:**
- 🔧 Build system improvements
- 📦 Packaging for distributions
- 🤖 CI/CD pipeline enhancements
- 🌐 Website and documentation site

### Good First Issues

Look for issues labeled:
- `good-first-issue` - Suitable for newcomers
- `help-wanted` - Actively seeking contributors
- `documentation` - Documentation improvements
- `testing` - Test coverage improvements

---

## How to Contribute

### Reporting Bugs

**Before reporting:**
1. Check existing issues for duplicates
2. Verify the bug on the latest version
3. Test on a clean installation

**Bug report should include:**
- Conduit version (`./conduit --help`)
- Operating system and version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs or error messages
- Platform details (`uname -a`)

**Use this template:**

```markdown
## Bug Description
[Clear description of the issue]

## Environment
- Conduit version: 1.0.0
- OS: Ubuntu 22.04 LTS
- Kernel: 5.15.0-generic

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Additional Context
[Logs, screenshots, etc.]
```

### Suggesting Features

**Feature requests should include:**
- Clear description of the feature
- Use case and motivation
- How it supports **authorized** security testing
- Compatibility considerations
- Potential implementation approach

**Use this template:**

```markdown
## Feature Description
[Clear description]

## Motivation
[Why this feature is needed]

## Use Case
[Specific authorized testing scenario]

## Implementation Ideas
[Optional: How it might be implemented]

## Alternatives Considered
[Other approaches you've thought about]
```

### Security Disclosures

**Security vulnerabilities should NOT be reported via public issues.**

See [SECURITY.md](SECURITY.md) for reporting procedures.

---

## Development Setup

### Prerequisites

```bash
# Debian/Ubuntu
sudo apt-get install build-essential libssl-dev libreadline-dev git

# RHEL/Fedora
sudo dnf install gcc make openssl-devel readline-devel git

# macOS
brew install gcc make openssl readline git
```

### Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/Conduit.git
cd Conduit

# Add upstream remote
git remote add upstream https://github.com/Real-Fruit-Snacks/Conduit.git
```

### Build for Development

```bash
# Build with debug symbols
make CFLAGS="-Wall -g -O0"

# Run tests
make test

# Test your changes
./conduit --help
./conduit --list-masq
```

### Creating a Branch

```bash
# Update main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/issue-description
```

---

## Coding Standards

### C Code Style

**General guidelines:**
- Follow existing code style in the project
- Match SOCAT's style for consistency
- Use meaningful variable names
- Comment complex logic

**Formatting:**
- Indentation: Tabs for block indentation, spaces for alignment
- Line length: 80 characters preferred, 120 maximum
- Braces: K&R style (opening brace on same line)
- Comments: `/* Block comments */` for documentation, `//` for inline

**Example:**

```c
/*
 * Function description
 * Returns 0 on success, -1 on error
 */
int stealth_hide_arguments(int argc, char **argv) {
    if (argc < 1 || argv == NULL) {
        return -1;  // Invalid arguments
    }

    // Platform-specific implementation
#ifdef __linux__
    prctl(PR_SET_NAME, "conduit", 0, 0, 0);
#endif

    return 0;
}
```

### Documentation

**Code comments should:**
- Explain "why", not "what" (code shows what)
- Document security implications
- Note platform-specific behavior
- Reference related issues/PRs

**Function documentation:**

```c
/*
 * stealth_hide_arguments - Hide process command-line arguments
 * @argc: Argument count
 * @argv: Argument vector
 *
 * Hides command-line arguments from process inspection tools using
 * platform-specific APIs. On Linux, uses prctl(). On BSD, uses
 * setproctitle(). Falls back to manual argv[] clearing on other platforms.
 *
 * Security: Does not protect against memory forensics or system call tracing.
 *
 * Returns: 0 on success, -1 on error
 */
```

### Security Considerations

**All contributions must:**
- Not introduce new security vulnerabilities
- Document security implications
- Consider both Linux and BSD platforms
- Avoid hardcoded secrets or credentials
- Use safe C functions (avoid strcpy, sprintf)

**Security checklist:**
- [ ] No buffer overflows
- [ ] No format string vulnerabilities
- [ ] No integer overflows
- [ ] Proper error handling
- [ ] Input validation
- [ ] Safe memory management

---

## Testing

### Running Tests

```bash
# Basic functionality tests
make test

# Manual testing
./conduit --help
./conduit --list-masq
./conduit --masq-kernel TCP-LISTEN:8080 TCP:example.com:80 &
ps aux | grep conduit
kill %1
```

### Platform Testing

**Test on multiple platforms:**
- Linux (Ubuntu, Debian, RHEL)
- FreeBSD
- OpenBSD
- macOS

### Adding Tests

When adding new features:
1. Add test cases to `Makefile`
2. Test both success and failure paths
3. Verify on multiple platforms
4. Document expected behavior

---

## Pull Request Process

### Before Submitting

**Checklist:**
- [ ] Code follows project style guidelines
- [ ] All tests pass (`make test`)
- [ ] New tests added for new features
- [ ] Documentation updated (README, comments)
- [ ] Commit messages are clear and descriptive
- [ ] Security implications considered and documented
- [ ] No legal or licensing issues
- [ ] Feature supports authorized use only

### Commit Messages

**Format:**

```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain the problem this commit solves and why this approach
was chosen.

- Bullet points are okay
- Use present tense ("Add feature" not "Added feature")
- Reference issues: "Fixes #123" or "Related to #456"
```

**Examples:**

```
Add FreeBSD support for process masquerading

Implements setproctitle()-based masquerading for FreeBSD.
Falls back to generic argv[] clearing on older versions.

Tested on FreeBSD 13.2 and 14.0.

Fixes #42
```

### Pull Request Template

```markdown
## Description
[Brief description of changes]

## Motivation
[Why is this change needed?]

## Testing
- [ ] Tested on Linux
- [ ] Tested on BSD/macOS
- [ ] All existing tests pass
- [ ] New tests added

## Security Considerations
[Any security implications of this change]

## Legal Compliance
- [ ] Supports authorized use only
- [ ] No licensing issues
- [ ] Proper copyright notices

## Related Issues
Fixes #[issue number]
```

### Review Process

1. **Submit PR** with clear description
2. **CI checks** must pass (build, test, security scan)
3. **Maintainer review** (may request changes)
4. **Address feedback** (commit changes to same branch)
5. **Approval** from at least one maintainer
6. **Merge** (squash or rebase as appropriate)

---

## Legal Requirements

### License Compliance

**All contributions must:**
- Be compatible with GPLv2 license
- Include proper copyright notices
- Not introduce incompatible dependencies
- Respect OpenSSL exception terms

### Copyright Notice

Add this to new files:

```c
/*
 * File: filename.c
 * Description: Brief description
 *
 * Copyright (C) 2026 Your Name
 * Copyright (C) 2026 Real-Fruit-Snacks
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
```

### Contributor License Agreement

By submitting a pull request, you agree that:
- Your contribution is your original work
- You have the right to submit it under GPLv2
- Your contribution may be distributed under GPLv2 terms
- You grant Real-Fruit-Snacks a perpetual license to use your contribution

### Ethical Use Commitment

By contributing, you affirm that:
- Your contribution supports authorized security testing
- You will not use Conduit for unauthorized access
- You understand the legal implications of security tools
- You have read and agree with [SECURITY.md](SECURITY.md)

---

## Questions?

- 💬 **GitHub Discussions**: For questions and community interaction
- 🐛 **GitHub Issues**: For bug reports and feature requests
- 📖 **Documentation**: Check README.md and docs/
- 🔒 **Security**: See SECURITY.md for security-related questions

---

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- GitHub contributors page
- Release notes for features/fixes

Thank you for helping make Conduit better! 🌊
