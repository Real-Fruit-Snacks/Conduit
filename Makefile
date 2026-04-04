# Conduit - Network Relay with Process Masquerading
# Makefile for building all components

CC = gcc
CFLAGS = -Wall -O2
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

# Targets
CONDUIT = conduit
SOCAT = socat-repo/socat

.PHONY: all clean install uninstall socat help test

all: $(CONDUIT) socat

# Build Conduit binary
$(CONDUIT): conduit.c
	@echo "Building Conduit..."
	$(CC) $(CFLAGS) -o $(CONDUIT) conduit.c
	@echo "✓ Conduit built successfully"

# Build stealth SOCAT
socat:
	@echo "Building stealth SOCAT..."
	@if [ ! -f socat-repo/Makefile ]; then \
		echo "Configuring SOCAT..."; \
		cd socat-repo && ./configure; \
	fi
	@cd socat-repo && $(MAKE)
	@echo "✓ Stealth SOCAT built successfully"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(CONDUIT)
	@if [ -f socat-repo/Makefile ]; then \
		cd socat-repo && $(MAKE) clean; \
	fi
	rm -f socat-repo/config.log socat-repo/config.status
	@echo "✓ Clean complete"

# Install binaries
install: all
	@echo "Installing binaries to $(BINDIR)..."
	install -d $(BINDIR)
	install -m 755 $(CONDUIT) $(BINDIR)/
	install -m 755 $(SOCAT) $(BINDIR)/socat-stealth
	@echo "✓ Installation complete"
	@echo "  - conduit -> $(BINDIR)/conduit"
	@echo "  - socat-stealth -> $(BINDIR)/socat-stealth"

# Uninstall binaries
uninstall:
	@echo "Uninstalling binaries..."
	rm -f $(BINDIR)/$(CONDUIT)
	rm -f $(BINDIR)/socat-stealth
	@echo "✓ Uninstall complete"

# Test Conduit binary
test: $(CONDUIT)
	@echo "Testing Conduit binary..."
	./$(CONDUIT) --help
	./$(CONDUIT) --list-masq
	@echo "✓ Basic tests passed"

# Help
help:
	@echo "Conduit Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all          - Build all components (default)"
	@echo "  conduit      - Build only Conduit binary"
	@echo "  socat        - Build only stealth SOCAT"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install binaries to $(PREFIX)"
	@echo "  uninstall    - Remove installed binaries"
	@echo "  test         - Run basic tests"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX       - Installation prefix (default: /usr/local)"
	@echo "  CC           - C compiler (default: gcc)"
	@echo "  CFLAGS       - Compiler flags (default: -Wall -O2)"
