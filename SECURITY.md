# Security Policy

## Intended Use

Conduit is a security research and penetration testing tool designed for **authorized use only**. This security policy addresses both:
1. Security vulnerabilities in Conduit itself
2. Responsible use of Conduit's capabilities

---

## Authorized Use Requirements

### ✅ Authorized Use Cases

Conduit may be used in the following contexts:

- **Penetration Testing**: With explicit written authorization from system owners
- **Red Team Operations**: Within authorized scope and rules of engagement
- **Security Research**: In controlled laboratory or sandboxed environments
- **CTF Competitions**: Capture The Flag events and security training exercises
- **Defensive Security**: Blue team tool development and defensive testing
- **Academic Research**: University and institutional research with proper ethics approval

### ❌ Prohibited Use Cases

The following uses are **strictly prohibited**:

- Unauthorized access to any computer system or network
- Malicious activities or criminal purposes
- Testing without explicit written permission
- Deployment on systems you do not own or control
- Bypassing security controls without authorization
- Any use that violates local, state, or federal laws

### Legal Compliance

**Users are solely responsible for:**
- Obtaining proper authorization before deployment
- Complying with all applicable laws and regulations
- Understanding the legal implications in their jurisdiction
- Maintaining documentation of authorization
- Operating within the scope of granted permissions

**Note**: Many jurisdictions have laws against unauthorized computer access (e.g., Computer Fraud and Abuse Act in the US, Computer Misuse Act in the UK). Violations can result in criminal prosecution, civil liability, and significant penalties.

---

## Reporting Security Vulnerabilities

### Scope

We accept vulnerability reports for:

- **Code Vulnerabilities**: Buffer overflows, memory leaks, injection flaws
- **Build Process**: Malicious dependencies, compromised build artifacts
- **Documentation**: Misleading security claims, incomplete warnings
- **License Compliance**: GPL violations, missing attributions

### Out of Scope

The following are **not** security vulnerabilities:

- Detection by security tools (expected behavior)
- Network traffic visibility (known limitation)
- Process masquerading limitations on specific platforms
- Social engineering or user error scenarios

### How to Report

**For security vulnerabilities in Conduit itself:**

1. **DO NOT** open a public GitHub issue
2. Email security reports to: [Create a security contact or use GitHub Security Advisories]
3. Include:
   - Vulnerability description
   - Steps to reproduce
   - Affected versions
   - Potential impact
   - Suggested fix (if available)

**For responsible disclosure:**
- We aim to respond within 48 hours
- We will work with you to understand and verify the issue
- We will credit you in the fix announcement (if desired)
- We follow a 90-day disclosure timeline

### GitHub Security Advisories

You can also report vulnerabilities through [GitHub Security Advisories](https://github.com/Real-Fruit-Snacks/Conduit/security/advisories):
1. Go to the Security tab
2. Click "Report a vulnerability"
3. Fill out the advisory form

---

## Supported Versions

| Version | Supported          | Notes |
| ------- | ------------------ | ----- |
| 1.0.x   | :white_check_mark: | Current release |
| < 1.0   | :x:                | Development versions - upgrade to 1.0+ |

---

## Security Features

### Built-in Security Measures

**Argument Hiding:**
- Prevents casual inspection of command-line arguments
- Platform-specific implementations (prctl, setproctitle)
- Mitigates information disclosure via process listing

**Process Masquerading:**
- Allows operation with non-suspicious process names
- Multiple preset identities for common scenarios
- Reduces likelihood of automated detection

### Known Limitations

**What Conduit DOES NOT protect against:**

| Detection Method | Protected | Notes |
|-----------------|-----------|-------|
| `ps`, `top`, `htop` | ✅ | Hidden |
| `/proc/<pid>/cmdline` | ✅ | Hidden |
| `/proc/<pid>/environ` | ⚠️ | Visible |
| System call tracing (`strace`) | ❌ | Fully visible |
| Network monitoring | ❌ | Traffic is not encrypted by default |
| Kernel security modules | ❌ | May detect process manipulation |
| EDR/XDR solutions | ❌ | Advanced monitoring may detect |
| Memory forensics | ❌ | Arguments recoverable from memory |

**Important**: Conduit is designed for authorized testing where some level of monitoring is expected. It is **not** a tool for evading sophisticated monitoring in unauthorized contexts.

---

## Threat Model

### Assumptions

**In Scope:**
- Hiding from basic system monitoring tools
- Reducing process listing footprint
- Authorized testing with known monitoring

**Out of Scope:**
- Evading advanced EDR/XDR systems
- Anti-forensics or evidence destruction
- Defeating kernel-level security modules
- Sophisticated network traffic analysis evasion

### Defender Perspective

**If you are a defender, you can detect Conduit by:**
1. Monitoring for process name changes (prctl syscalls)
2. Network traffic analysis (relay patterns)
3. System call tracing (strace, dtrace, eBPF)
4. Memory inspection (argv recovery)
5. File integrity monitoring (unauthorized binaries)
6. Behavioral analysis (unusual network connections)

---

## Build Security

### Verifying Releases

**When downloading pre-built binaries:**

1. Verify GPG signatures (when available)
2. Compare checksums against published hashes
3. Build from source for maximum assurance

**When building from source:**

```bash
# Verify git commit signatures
git log --show-signature

# Review code before building
grep -r "system\|exec\|eval" .

# Build with debug symbols for analysis
make CFLAGS="-Wall -g -O0"
```

### Supply Chain Security

- **Source Code**: Hosted on GitHub with commit signing
- **Base**: Built on SOCAT 1.7.3.3 (well-established project)
- **Dependencies**: Minimal (OpenSSL, readline - both optional)
- **Build Process**: Standard make + autoconf (no npm/pip dependencies)

---

## Secure Deployment Practices

### Operational Security

**Before deployment:**
1. ✅ Obtain explicit written authorization
2. ✅ Document scope and limitations
3. ✅ Understand monitoring in target environment
4. ✅ Plan for detection and response
5. ✅ Establish communication channels

**During operation:**
1. ✅ Operate only within authorized scope
2. ✅ Maintain audit logs of activities
3. ✅ Monitor for unexpected behavior
4. ✅ Be prepared to explain presence to defenders
5. ✅ Coordinate with blue team (if applicable)

**After operation:**
1. ✅ Remove all deployed binaries
2. ✅ Document activities performed
3. ✅ Report findings to system owners
4. ✅ Verify cleanup with defenders
5. ✅ Update authorization documentation

### Credential Management

**Conduit does not store credentials**, but when using with authentication:

- Never hardcode credentials in command lines
- Use environment variables or config files with restricted permissions
- Rotate credentials after testing
- Securely delete credentials from memory after use

---

## Incident Response

### If Conduit is Detected

**During authorized testing:**
1. Immediately contact the system owner
2. Provide authorization documentation
3. Explain the testing activity
4. Coordinate with security team
5. Document the detection method

**If used without authorization (by others):**
1. Treat as a security incident
2. Collect evidence (process details, network connections)
3. Isolate affected systems if necessary
4. Review authorization documentation
5. Report to appropriate authorities

---

## Security Contacts

- **Vulnerability Reports**: Use GitHub Security Advisories
- **General Security Questions**: Open a GitHub Discussion
- **Responsible Disclosure**: Follow 90-day timeline
- **Legal/Compliance**: Contact repository maintainers

---

## License and Liability

Conduit is licensed under GPLv2 with OpenSSL exception.

```
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
THE AUTHORS ARE NOT LIABLE FOR ANY DAMAGES ARISING FROM USE.
```

**By using Conduit, you accept:**
- All security limitations described in this document
- Full responsibility for authorized and lawful use
- Liability for any misuse or unauthorized deployment
- The terms of the GNU General Public License version 2

---

## References

- [Computer Fraud and Abuse Act (CFAA)](https://www.justice.gov/criminal-ccips/ccmanual)
- [OWASP Penetration Testing Methodologies](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [Original SOCAT Security](http://www.dest-unreach.org/socat/doc/SECURITY)

---

**Last Updated**: 2026-04-03  
**Version**: 1.0.0
