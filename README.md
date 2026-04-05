<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-light.svg">
  <img alt="Conduit" src="https://raw.githubusercontent.com/Real-Fruit-Snacks/Conduit/main/docs/assets/logo-dark.svg" width="520">
</picture>

![C](https://img.shields.io/badge/language-C-orange.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20BSD%20%7C%20macOS-lightgrey)
![License](https://img.shields.io/badge/license-GPLv2-blue.svg)

**SOCAT-based network relay with kernel-level process masquerading.**

Full bidirectional relay with 50+ channel types. Process name manipulation via prctl/setproctitle. Argument memory zeroing across /proc boundaries. Zero configuration stealth.

> **Authorization Required**: Designed exclusively for authorized security testing with explicit written permission.

</div>

---

## Quick Start

**Prerequisites:** GCC, GNU Make, OpenSSL (optional)

```bash
git clone https://github.com/Real-Fruit-Snacks/Conduit.git
cd Conduit
make
```

**Verify:**

```bash
./conduit --help
./conduit --list-masq
```

---

## Features

### Process Masquerading

Hide in plain sight. Choose a preset identity or define your own.

```bash
./conduit -Mk TCP-LISTEN:8080,fork TCP:10.0.0.5:80    # kernel worker [kworker/0:1]
./conduit -Ms TCP-LISTEN:8080,fork TCP:backend:80       # systemd-logind
./conduit -MS TCP-LISTEN:2222 TCP:internal-ssh:22       # /usr/sbin/sshd
./conduit -Mn UDP-LISTEN:53,fork UDP:8.8.8.8:53         # NetworkManager
./conduit -Mc 'nginx: worker process' TCP-LISTEN:443 TCP:app:8443  # custom name
```

### Argument Hiding

Command-line arguments erased from /proc after parsing. Survives `ps`, `top`, `htop` inspection.

```bash
./conduit -Mk TCP-LISTEN:8080,fork TCP:10.0.0.5:80 &
ps aux | grep conduit    # arguments hidden
ps aux | grep kworker    # appears as kernel worker
```

### Advanced Stealth

PID targeting, OOM immunity, port range control, environment sanitization, and time namespace matching.

```bash
sudo ./conduit -Ms -Mp 500 TCP-LISTEN:8080 TCP:target:80           # target specific PID
sudo ./conduit -Ms -Mo TCP-LISTEN:443,fork TCP:backend:443          # OOM immune
sudo ./conduit -Ms -MP 49152-65535 -Me TCP-LISTEN:8080 TCP:target:80  # port range + env clean
sudo ./conduit -Ms -Mt 500 TCP-LISTEN:8080 TCP:target:80            # match process start time
```

### Full SOCAT Compatibility

100+ configuration options. TCP, UDP, UNIX, SSL/TLS, SOCKS, file, PTY — all 50+ channel types work unchanged. No functionality sacrificed for stealth.

```bash
./conduit -Ms OPENSSL:server:443,verify=0 TCP-LISTEN:8080,fork     # SSL/TLS
./conduit -Mk SOCKS4A:proxy:target:80 TCP-LISTEN:1080              # SOCKS proxy
./conduit -Ms UNIX-CONNECT:/var/run/docker.sock TCP-LISTEN:2375     # UNIX socket
```

---

## Architecture

```
Conduit/
├── socat-repo/
│   ├── socat.c          # Main relay + masquerading (-Mk, -Ms, -MS, -Mn, -Md, -Mr, -Mc)
│   ├── xio-tcp.c        # TCP channels
│   ├── xio-openssl.c    # SSL/TLS channels
│   ├── xio-socks.c      # SOCKS proxy
│   └── [48 more xio-*]  # Other channel types
├── Makefile
└── docs/
```

Three-stage execution: parse masquerade flag → apply identity via platform-native API (prctl on Linux, setproctitle on BSD, argv zeroing as fallback) → start SOCAT relay. Masquerading is transparent to relay logic.

---

## Platform Support

| | Linux | FreeBSD | OpenBSD | macOS |
|---|---|---|---|---|
| Process masquerade | prctl | setproctitle | setproctitle | Limited |
| Argument hiding | Full | Full | Full | Full |
| Relay | Full | Full | Full | Full |
| PID targeting | Root | — | — | — |
| OOM immunity | Root | — | — | — |
| Time matching | Kernel 5.6+ | — | — | — |

---

## Security

Report vulnerabilities via [GitHub Security Advisories](https://github.com/Real-Fruit-Snacks/Conduit/security/advisories). 90-day responsible disclosure.

**Conduit does not:**
- Evade strace, dtrace, or eBPF syscall tracing
- Hide network traffic patterns or connection metadata
- Defeat EDR/XDR behavioral analysis
- Bypass kernel security modules (SELinux, AppArmor)

---

## License

[GPLv2](LICENSE) with OpenSSL exception — Copyright 2026 Real-Fruit-Snacks. Based on SOCAT 1.7.3.3 by Gerhard Rieger.
