<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-light.svg">
  <img alt="Conduit" src="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-dark.svg" width="400">
</picture>

![C](https://img.shields.io/badge/language-C-orange.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20BSD%20%7C%20macOS-lightgrey)
![License](https://img.shields.io/badge/license-GPLv2-blue.svg)

**SOCAT-based network relay with kernel-level process masquerading**

Process name manipulation via prctl/setproctitle. Argument memory zeroing across /proc boundaries. Full bidirectional relay with 50+ channel types. Zero configuration stealth.

> **Authorization Required**: This tool is designed exclusively for authorized security testing with explicit written permission. Unauthorized access to computer systems is illegal and may result in criminal prosecution.

[Quick Start](#quick-start) • [Architecture](#architecture) • [Stealth Modules](#stealth-modules) • [Security](#security)

</div>

---

## Highlights

<markdown-accessiblity-table><table>
<tr>
<td width="50%">

**Process Masquerading**  
Platform-native APIs transform process identity. Linux prctl() for kernel workers. BSD setproctitle() for system services. Generic argv[] memory manipulation fallback.

**Argument Hiding**  
Command-line arguments erased from /proc filesystem. Memory boundaries overwritten post-parse. Survives ps, top, htop inspection. Microsecond overhead.

**Full SOCAT Compatibility**  
100+ configuration options preserved. 50+ data channel types. TCP/UDP/UNIX/SSL/TLS/SOCKS support. No functionality sacrificed for stealth.

**Multi-Platform**  
Native Linux implementation (prctl). BSD family support (setproctitle). macOS partial compatibility. Solaris/AIX generic fallback.

</td>
<td width="50%">

**Unified Binary**  
Single Conduit executable with integrated stealth. SOCAT 1.7.3.3 core with masquerading options. No separate wrapper or utility binaries required. Seamless deployment.

**Built-In Presets**  
Kernel worker masquerading (-Mk). System service identities (-Ms). SSH daemon impersonation (-MS). Random process selection (-Mn). Custom names (-Md). Argument-only hiding (-Mr, -Mc).

**Detection Awareness**  
Documented evasion boundaries. Known EDR/XDR limitations. Network traffic remains visible. Kernel security module considerations.

**Operational Security**  
Legal compliance emphasis. Defender detection methods documented. Authorization requirement framework. Incident response procedures.

</td>
</tr>
</table></markdown-accessiblity-table>

---

## Quick Start

### Prerequisites

<markdown-accessiblity-table><table>
<tr>
<th>Requirement</th>
<th>Version</th>
<th>Purpose</th>
</tr>
<tr>
<td>GCC</td>
<td>Any</td>
<td>C compiler</td>
</tr>
<tr>
<td>GNU Make</td>
<td>Any</td>
<td>Build system</td>
</tr>
<tr>
<td>OpenSSL</td>
<td>Optional</td>
<td>SSL/TLS channels</td>
</tr>
<tr>
<td>GNU Readline</td>
<td>Optional</td>
<td>Interactive features</td>
</tr>
</table></markdown-accessiblity-table>

### Build

```bash
# Clone repository
git clone https://github.com/Real-Fruit-Snacks/Conduit.git
cd Conduit

# Build the unified binary
make

# Verify build
./conduit --help
./conduit --list-masq
```

### Verification

```bash
# Test with kernel worker masquerading
./conduit -Mk TCP-LISTEN:8080,fork TCP:10.0.0.5:80 &
ps aux | grep conduit    # Arguments hidden
ps aux | grep kworker    # Appears as kernel worker

# List all masquerading presets
./conduit --help

# Clean up
killall conduit
```

---

## Execution Flow

### Stage 1: Option Parsing
1. **Parse masquerade flag** — Check for -M* options
   - `-Mk` = kernel worker
   - `-Ms` = system service
   - `-MS` = SSH daemon
   - `-Mn` = random process
   - `-Md <name>` = custom name
   - `-Mr` = argument hiding only
   - `-Mc` = config preset
2. **Parse SOCAT arguments** — Standard SOCAT command-line processing
3. **Platform detection** — Identify prctl/setproctitle availability

### Stage 2: Masquerading Setup
```c
// In socat.c main() before relay starts:
if (masq_option_set) {
    apply_masquerade(masq_type, masq_name);
}

// Platform-specific implementation:
#ifdef __linux__
    prctl(PR_SET_NAME, process_name, 0, 0, 0);
#elif defined(__FreeBSD__) || defined(__OpenBSD__)
    setproctitle("%s", process_name);
#else
    // Generic fallback: zero argv memory
    for (int i = 1; i < argc; i++) {
        memset(argv[i], 0, strlen(argv[i]));
    }
#endif

// Always zero argument strings
memset(argv[0], 0, strlen(argv[0]));
for (int i = 1; i < argc; i++) {
    memset(argv[i], 0, strlen(argv[i]));
}
```

### Stage 3: Relay Execution
- Masquerading transparent to relay logic
- All SOCAT features operational
- No performance degradation
- Bidirectional data flow maintained

---

## Components

### Conduit Binary

**Unified executable** with integrated stealth. SOCAT 1.7.3.3 with built-in masquerading options.

#### Process Masquerading Options

<markdown-accessiblity-table><table>
<tr>
<th>Option</th>
<th>Process Name</th>
<th>Use Case</th>
</tr>
<tr>
<td><code>-Ms</code></td>
<td><code>systemd-logind</code></td>
<td>System service daemon</td>
</tr>
<tr>
<td><code>-MS</code></td>
<td><code>/usr/sbin/sshd</code></td>
<td>SSH server process</td>
</tr>
<tr>
<td><code>-Mn</code></td>
<td><code>NetworkManager</code></td>
<td>Network service</td>
</tr>
<tr>
<td><code>-Md</code></td>
<td><code>dbus-daemon</code></td>
<td>D-Bus message bus</td>
</tr>
<tr>
<td><code>-Mr</code></td>
<td><code>systemd-resolved</code></td>
<td>DNS resolver service</td>
</tr>
<tr>
<td><code>-Mc &lt;name&gt;</code></td>
<td>Custom string</td>
<td>User-defined identity</td>
</tr>
</table></markdown-accessiblity-table>

#### Advanced Stealth Options

<markdown-accessiblity-table><table>
<tr>
<th>Option</th>
<th>Description</th>
<th>Requirements</th>
</tr>
<tr>
<td><code>-Mp &lt;pid&gt;</code></td>
<td>Target specific PID by manipulating <code>/proc/sys/kernel/ns_last_pid</code>. Process will attempt to receive the specified PID.</td>
<td>Root or CAP_SYS_ADMIN (Linux only)</td>
</tr>
<tr>
<td><code>-Mo</code></td>
<td>Enable OOM immunity by setting <code>/proc/self/oom_score_adj</code> to -1000. Prevents Linux OOM killer termination.</td>
<td>Root or appropriate capabilities</td>
</tr>
<tr>
<td><code>-MP &lt;range&gt;</code></td>
<td>Set ephemeral port range (e.g., <code>49152-65535</code>) by writing to <code>/proc/sys/net/ipv4/ip_local_port_range</code>.</td>
<td>Root or CAP_NET_ADMIN</td>
</tr>
<tr>
<td><code>-Me</code></td>
<td>Sanitize environment by removing <code>SSH_*</code>, <code>SUDO_*</code>, <code>DISPLAY</code>, <code>XAUTHORITY</code>, and other forensic artifacts.</td>
<td>None</td>
</tr>
<tr>
<td><code>-Mt &lt;pid&gt;</code></td>
<td>Match start time of target PID using time namespaces. Process appears with same start time in <code>ps</code> output.</td>
<td>Kernel 5.6+, CAP_SYS_ADMIN</td>
</tr>
</table></markdown-accessiblity-table>

**Basic Usage:**
```bash
# Masquerade as systemd service
./conduit -Ms TCP-LISTEN:8080,fork TCP:backend:80

# Masquerade as SSH daemon
./conduit -MS TCP-LISTEN:2222 TCP:internal-ssh:22

# Custom process name
./conduit -Mc 'nginx: worker process' TCP-LISTEN:443 TCP:app:8443

# NetworkManager masquerade
./conduit -Mn UDP-LISTEN:53,fork UDP:8.8.8.8:53
```

**Advanced Stealth:**
```bash
# Target specific PID (requires root)
sudo ./conduit -Ms -Mp 500 TCP-LISTEN:8080 TCP:target:80

# OOM immunity for persistent relay
sudo ./conduit -Ms -Mo TCP-LISTEN:443,fork TCP:backend:443

# Port range control with environment sanitization
sudo ./conduit -Ms -MP 49152-65535 -Me TCP-LISTEN:8080 TCP:target:80

# Match target process start time (requires kernel 5.6+)
sudo ./conduit -Ms -Mt 500 TCP-LISTEN:8080 TCP:target:80

# Full process impersonation (PID + start time + OOM immunity)
sudo ./conduit -Ms -Mp 500 -Mt 500 -Mo -Me TCP-LISTEN:443 TCP:backend:443
```

---

## Stealth Modules

### Platform-Specific Implementations

<markdown-accessiblity-table><table>
<tr>
<th>Module</th>
<th>File</th>
<th>Description</th>
</tr>
<tr>
<td>Linux prctl masquerading</td>
<td><code>socat-repo/socat.c (masq_prctl)</code></td>
<td>Kernel process name manipulation via PR_SET_NAME. Overwrites /proc/self/comm. Requires CAP_SYS_RESOURCE or same UID.</td>
</tr>
<tr>
<td>BSD setproctitle masquerading</td>
<td><code>socat-repo/socat.c (masq_setproctitle)</code></td>
<td>libc-provided process title modification. Updates ps output directly. Available on FreeBSD, OpenBSD, NetBSD.</td>
</tr>
<tr>
<td>Generic argv zeroing</td>
<td><code>socat-repo/socat.c (masq_argv_clear)</code></td>
<td>Direct memory manipulation of argv array. Zeroes argument strings. Fallback for platforms without native APIs.</td>
</tr>
<tr>
<td>Kernel worker preset</td>
<td><code>socat-repo/socat.c (-Mk option)</code></td>
<td>Masquerade as Linux kernel worker thread [kworker/0:1].</td>
</tr>
<tr>
<td>System service preset</td>
<td><code>socat-repo/socat.c (-Ms option)</code></td>
<td>Masquerade as system service (systemd-logind).</td>
</tr>
<tr>
<td>SSH daemon preset</td>
<td><code>socat-repo/socat.c (-MS option)</code></td>
<td>Masquerade as SSH server (/usr/sbin/sshd).</td>
</tr>
<tr>
<td>Random process preset</td>
<td><code>socat-repo/socat.c (-Mn option)</code></td>
<td>Random system process selection from pool of common services.</td>
</tr>
<tr>
<td>Custom name option</td>
<td><code>socat-repo/socat.c (-Md option)</code></td>
<td>User-specified custom process name masquerading.</td>
</tr>
<tr>
<td>Argument hiding only</td>
<td><code>socat-repo/socat.c (-Mr option)</code></td>
<td>Zero arguments without changing process name. Preserves /proc/self/comm.</td>
</tr>
<tr>
<td>Config preset</td>
<td><code>socat-repo/socat.c (-Mc option)</code></td>
<td>Load masquerade configuration from file or preset identifier.</td>
</tr>
</table></markdown-accessiblity-table>

### Detection Considerations

**Hidden from:**
- `ps aux` — Process list shows masqueraded name
- `/proc/<pid>/cmdline` — Arguments zeroed in memory
- `top`, `htop` — Interactive monitors display false identity
- Basic process inspection — Casual observation defeated

**Visible to:**
- `strace`, `dtrace` — System call tracing reveals true behavior
- Network monitoring — Traffic patterns unchanged
- EDR/XDR solutions — Behavioral analysis may detect anomalies
- Kernel security modules — SELinux/AppArmor may flag modifications
- Memory forensics — Arguments recoverable from RAM dumps

---

## SOCAT Channel Types

### Supported Transports

<markdown-accessiblity-table><table>
<tr>
<th>Category</th>
<th>Type</th>
<th>Syntax</th>
<th>Example</th>
</tr>
<tr>
<td rowspan="2">TCP</td>
<td>Connect</td>
<td><code>TCP:&lt;host&gt;:&lt;port&gt;</code></td>
<td><code>TCP:example.com:80</code></td>
</tr>
<tr>
<td>Listen</td>
<td><code>TCP-LISTEN:&lt;port&gt;</code></td>
<td><code>TCP-LISTEN:8080,fork</code></td>
</tr>
<tr>
<td rowspan="2">UDP</td>
<td>Datagram</td>
<td><code>UDP:&lt;host&gt;:&lt;port&gt;</code></td>
<td><code>UDP:8.8.8.8:53</code></td>
</tr>
<tr>
<td>Listen</td>
<td><code>UDP-LISTEN:&lt;port&gt;</code></td>
<td><code>UDP-LISTEN:53,fork</code></td>
</tr>
<tr>
<td rowspan="2">UNIX</td>
<td>Connect</td>
<td><code>UNIX-CONNECT:&lt;path&gt;</code></td>
<td><code>UNIX-CONNECT:/var/run/docker.sock</code></td>
</tr>
<tr>
<td>Listen</td>
<td><code>UNIX-LISTEN:&lt;path&gt;</code></td>
<td><code>UNIX-LISTEN:/tmp/control.sock</code></td>
</tr>
<tr>
<td>SSL/TLS</td>
<td>Secure</td>
<td><code>OPENSSL:&lt;host&gt;:&lt;port&gt;</code></td>
<td><code>OPENSSL:server:443,verify=0</code></td>
</tr>
<tr>
<td>SOCKS</td>
<td>Proxy</td>
<td><code>SOCKS4A:&lt;proxy&gt;:&lt;target&gt;:&lt;port&gt;</code></td>
<td><code>SOCKS4A:proxy:target:80</code></td>
</tr>
<tr>
<td>File</td>
<td>I/O</td>
<td><code>FILE:&lt;path&gt;</code></td>
<td><code>FILE:/var/log/output.log,create</code></td>
</tr>
<tr>
<td>PTY</td>
<td>Terminal</td>
<td><code>PTY</code></td>
<td><code>PTY,link=/tmp/pty</code></td>
</tr>
</table></markdown-accessiblity-table>

*See `socat-repo/doc/socat.html` for complete reference (50+ types).*

---

## Architecture

```
Conduit/
├── Makefile                         # Build orchestration
│
├── socat-repo/                      # SOCAT 1.7.3.3 with integrated stealth
│   ├── socat.c                     # Main relay + masquerading options
│   │                                # Integrated -Mk, -Ms, -MS, -Mn, -Md, -Mr, -Mc
│   │
│   ├── xio-tcp.c                   # TCP channel implementation
│   ├── xio-unix.c                  # UNIX socket channels
│   ├── xio-openssl.c               # SSL/TLS encryption
│   ├── xio-socks.c                 # SOCKS proxy support
│   ├── [48 additional xio-*.c]     # Other channel types
│   │
│   ├── error.c, sysutils.c         # Support libraries
│   ├── configure                   # Autoconf build system
│   └── doc/                        # Original SOCAT docs
│
├── docs/
│   └── index.html                  # GitHub Pages site
│
├── .github/workflows/
│   └── ci.yml                      # Multi-platform CI/CD
│
├── README.md                        # This file
├── LICENSE                          # GPLv2 + OpenSSL exception
├── SECURITY.md                      # Security policy
├── CONTRIBUTING.md                  # Contribution guidelines
├── INSTALL.md                       # Installation guide
└── CHANGELOG.md                     # Version history
```

### Component Flow

```
┌─────────────────────────────────────────────────────────────┐
│                Unified Conduit Binary Flow                  │
└─────────────────────────────────────────────────────────────┘
                              │
                      ┌───────▼─────────┐
                      │  Conduit Binary │
                      │  (conduit/socat)│
                      └───────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
       ┌──────▼─────┐  ┌──────▼──────┐ ┌─────▼──────┐
       │ Parse -M*  │  │  socat.c    │ │  xio-*.c   │
       │ options    │  │  Main loop  │ │  Channels  │
       └──────┬─────┘  └─────────────┘ └────────────┘
              │
     ┌────────┴────────────────────┐
     │                             │
 ┌───▼────┐  ┌──────────┐  ┌──────▼─────┐
 │ prctl  │  │setproctitle│ │argv[] zero  │
 │(Linux) │  │(BSD/macOS) │ │ (generic)   │
 │-Mk,-Md │  │-Ms,-MS,-Mn │ │ -Mr,-Mc     │
 └────────┘  └────────────┘ └─────────────┘
```

---

## Configuration

### Compile-Time Options

<markdown-accessiblity-table><table>
<tr>
<th>Setting</th>
<th>Makefile Variable</th>
<th>Default</th>
<th>Notes</th>
</tr>
<tr>
<td>Compiler</td>
<td><code>CC</code></td>
<td><code>gcc</code></td>
<td>C compiler binary</td>
</tr>
<tr>
<td>Flags</td>
<td><code>CFLAGS</code></td>
<td><code>-Wall -O2</code></td>
<td>Compilation options</td>
</tr>
<tr>
<td>Install prefix</td>
<td><code>PREFIX</code></td>
<td><code>/usr/local</code></td>
<td>Installation directory</td>
</tr>
<tr>
<td>Binary dir</td>
<td><code>BINDIR</code></td>
<td><code>$(PREFIX)/bin</code></td>
<td>Executable location</td>
</tr>
</table></markdown-accessiblity-table>

### Build Targets

```bash
# Build unified binary
make

# Build specific binary
make conduit

# Installation
sudo make install PREFIX=/opt/conduit

# Cleanup
make clean
```

### Debug Build

```bash
# Build with symbols and no optimization
make CFLAGS="-Wall -g -O0"

# Verify build with help
./conduit -h
```

---

## Operational Security

### Authorization Framework

**Required before deployment:**
- ✅ Explicit written authorization from system owners
- ✅ Documented scope of authorized testing
- ✅ Incident response coordination with defenders
- ✅ Communication channel establishment
- ✅ Legal compliance verification

**During operations:**
- ✅ Operate only within authorized scope
- ✅ Maintain detailed activity logs
- ✅ Monitor for unexpected behavior
- ✅ Coordinate with blue team (if applicable)
- ✅ Be prepared to explain presence

**After operations:**
- ✅ Remove all deployed binaries
- ✅ Document findings for system owners
- ✅ Verify cleanup with defenders
- ✅ Update authorization records
- ✅ Conduct lessons learned review

### Detection Mitigation

**Process masquerading effectiveness:**
- Defeats casual inspection (ps, top, htop)
- Survives basic monitoring tools
- Requires advanced detection (EDR, syscall tracing)

**Known limitations:**
- Network traffic remains visible
- System call patterns detectable
- Memory forensics recovers arguments
- Behavioral analysis may flag anomalies

**Defender capabilities:**
1. Monitor prctl/setproctitle syscalls
2. Analyze network connection patterns
3. Trace system calls with strace/eBPF
4. Inspect process memory with GDB
5. Deploy EDR/XDR behavioral analysis

### Legal Compliance

**United States:**
- Computer Fraud and Abuse Act (CFAA) prohibits unauthorized access
- Authorization must be explicit and documented
- Exceeding authorized scope constitutes violation

**United Kingdom:**
- Computer Misuse Act criminalizes unauthorized access
- Intent and knowledge of unauthorized use relevant
- Authorization defense requires clear evidence

**European Union:**
- Various national laws criminalize unauthorized access
- GDPR considerations for data processed during testing
- Explicit consent required from data controllers

**User Responsibility:**
- Verify legal requirements in your jurisdiction
- Obtain written authorization before deployment
- Maintain comprehensive documentation
- Consult legal counsel when uncertain

---

## Platform Support

<markdown-accessiblity-table><table>
<tr>
<th>Platform</th>
<th>Argument Hiding</th>
<th>Process Masquerading</th>
<th>Status</th>
</tr>
<tr>
<td>Linux</td>
<td>✅ prctl</td>
<td>✅ Full support</td>
<td>Tested</td>
</tr>
<tr>
<td>FreeBSD</td>
<td>✅ setproctitle</td>
<td>✅ Full support</td>
<td>Tested</td>
</tr>
<tr>
<td>OpenBSD</td>
<td>✅ setproctitle</td>
<td>✅ Full support</td>
<td>Tested</td>
</tr>
<tr>
<td>macOS</td>
<td>✅ setproctitle</td>
<td>⚠️ Limited</td>
<td>Tested</td>
</tr>
<tr>
<td>Solaris</td>
<td>⚠️ Generic fallback</td>
<td>⚠️ Limited</td>
<td>Untested</td>
</tr>
<tr>
<td>AIX</td>
<td>⚠️ Generic fallback</td>
<td>⚠️ Limited</td>
<td>Untested</td>
</tr>
</table></markdown-accessiblity-table>

---

## Security

### Vulnerability Reporting

**Report security issues via:**
- GitHub Security Advisories (preferred)
- Private disclosure to maintainers
- Responsible disclosure timeline (90 days)

**Do NOT:**
- Open public GitHub issues for vulnerabilities
- Disclose before coordination with maintainers
- Exploit vulnerabilities in unauthorized contexts

### Threat Model

**In scope:**
- Hiding from basic process inspection
- Masquerading as legitimate processes
- Authorized testing with known monitoring

**Out of scope:**
- Evading advanced EDR/XDR systems
- Anti-forensics or evidence destruction
- Defeating kernel security modules
- Sophisticated traffic analysis evasion

### Known Limitations

**Conduit does NOT protect against:**
- Advanced system call tracing
- Network traffic analysis
- Kernel security modules (SELinux, AppArmor)
- EDR/XDR behavioral monitoring
- Memory forensics investigation

**Use within authorized scope and understand monitoring capabilities.**

---

## License

GNU General Public License version 2 (GPLv2) with OpenSSL linking exception.

**Copyright:**
- **Conduit modifications**: Copyright © 2026 Real-Fruit-Snacks
- **Original SOCAT**: Copyright © 2001-2023 Gerhard Rieger and contributors

See [LICENSE](LICENSE) for complete terms.

```
THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
THE AUTHORS ARE NOT LIABLE FOR ANY DAMAGES ARISING FROM USE.
USE AT YOUR OWN RISK.
```

---

## Resources

- **Original SOCAT**: http://www.dest-unreach.org/socat/
- **Documentation**: `socat-repo/doc/socat.html`
- **Examples**: `socat-repo/EXAMPLES`
- **Security Policy**: [SECURITY.md](SECURITY.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **GitHub**: https://github.com/Real-Fruit-Snacks/Conduit

---

<div align="center">

**Part of the Real-Fruit-Snacks water-themed security toolkit**

[Tidepool](https://github.com/Real-Fruit-Snacks/Tidepool) • [Riptide](https://github.com/Real-Fruit-Snacks/Riptide) • [Cascade](https://github.com/Real-Fruit-Snacks/Cascade) • [Slipstream](https://github.com/Real-Fruit-Snacks/Slipstream) • [HydroShot](https://github.com/Real-Fruit-Snacks/HydroShot) • [Aquifer](https://github.com/Real-Fruit-Snacks/Aquifer) • **Conduit**

*Remember: With great power comes great responsibility.* 🌊

</div>
