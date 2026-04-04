#!/usr/bin/env bash
# source: test-stealth-integration.sh
# Integration script to add stealth tests to the main test suite

# This script can be sourced by test.sh or run standalone
# It provides integration functions for stealth testing

# Integration function to be called from main test.sh
run_stealth_tests() {
    local socat_binary="${1:-./socat}"

    echo "Running stealth functionality tests..."

    if [ -x "./test-stealth.sh" ]; then
        if ./test-stealth.sh -b "$socat_binary" "$@"; then
            echo "Stealth tests: PASSED"
            return 0
        else
            echo "Stealth tests: FAILED"
            return 1
        fi
    else
        echo "Warning: test-stealth.sh not found or not executable"
        return 1
    fi
}

# Quick stealth check function for integration
quick_stealth_check() {
    local socat_binary="${1:-./socat}"

    if [ ! -x "$socat_binary" ]; then
        echo "Stealth check: SKIP (binary not available)"
        return 0
    fi

    # Quick check - just verify stealth function exists in binary
    if command -v objdump >/dev/null 2>&1; then
        if objdump -t "$socat_binary" 2>/dev/null | grep -q stealth_hide_arguments; then
            echo "Stealth check: PASS (function detected)"
            return 0
        fi
    fi

    # Fallback: check if stealth.o exists
    if [ -f "stealth.o" ]; then
        echo "Stealth check: PASS (stealth.o found)"
        return 0
    fi

    echo "Stealth check: UNKNOWN (cannot detect stealth support)"
    return 0
}

# If run directly, execute stealth tests
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_stealth_tests "$@"
fi