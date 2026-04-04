# Conduit - Network Relay with Process Masquerading
# Makefile for building all components

CC = gcc
CFLAGS = -Wall -O2
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin

# Targets
CONDUIT = socat-repo/conduit

.PHONY: all clean install uninstall conduit help test

all: conduit

# Build Conduit (integrated SOCAT with stealth + masquerading)
conduit:
	@echo "Building Conduit..."
	@if [ ! -f socat-repo/Makefile ]; then \
		echo "Configuring Conduit..."; \
		cd socat-repo && ./configure; \
	fi
	@cd socat-repo && $(MAKE) conduit
	@echo "✓ Conduit built successfully"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@if [ -f socat-repo/Makefile ]; then \
		cd socat-repo && $(MAKE) clean; \
	fi
	rm -f socat-repo/config.log socat-repo/config.status
	@echo "✓ Clean complete"

# Install binaries
install: all
	@echo "Installing binaries to $(BINDIR)..."
	install -d $(BINDIR)
	install -m 755 $(CONDUIT) $(BINDIR)/conduit
	@echo "✓ Installation complete"
	@echo "  - conduit -> $(BINDIR)/conduit"

# Uninstall binaries
uninstall:
	@echo "Uninstalling binaries..."
	rm -f $(BINDIR)/conduit
	@echo "✓ Uninstall complete"

# Test Conduit binary
test: conduit
	@echo "Testing Conduit binary..."
	$(CONDUIT) -h | head -5
	@echo "✓ Basic tests passed"

# Help
help:
	@echo "Conduit Build System"
	@echo ""
	@echo "Targets:"
	@echo "  all          - Build Conduit (default)"
	@echo "  conduit      - Build Conduit binary"
	@echo "  clean        - Remove build artifacts"
	@echo "  install      - Install binary to $(PREFIX)"
	@echo "  uninstall    - Remove installed binary"
	@echo "  test         - Run basic tests"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX       - Installation prefix (default: /usr/local)"
	@echo "  CC           - C compiler (default: gcc)"
	@echo "  CFLAGS       - Compiler flags (default: -Wall -O2)"
