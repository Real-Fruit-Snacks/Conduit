#!/usr/bin/env bash
# source: test-stealth-utils.sh
# Utility functions for stealth testing - can be sourced by other test scripts

# Stealth testing utility functions
# These functions provide reusable components for testing stealth functionality

# Color definitions (only if stdout is a terminal)
if [ -t 1 ]; then
    STEALTH_RED='\033[0;31m'
    STEALTH_GREEN='\033[0;32m'
    STEALTH_YELLOW='\033[1;33m'
    STEALTH_BLUE='\033[0;34m'
    STEALTH_NC='\033[0m'
else
    STEALTH_RED=''
    STEALTH_GREEN=''
    STEALTH_YELLOW=''
    STEALTH_BLUE=''
    STEALTH_NC=''
fi

# Utility: Check if a process is hiding its arguments
# Usage: check_process_stealth PID "expected_visible_args" "should_not_contain"
check_process_stealth() {
    local pid="$1"
    local expected_visible="$2"
    local should_not_contain="$3"
    local result=0

    # Check ps output
    local ps_output
    ps_output=$(ps -p "$pid" -o args= 2>/dev/null || echo "")

    if [ -z "$ps_output" ]; then
        echo "Process $pid not found in ps output"
        return 1
    fi

    # Check if sensitive args are hidden
    if [ -n "$should_not_contain" ] && echo "$ps_output" | grep -q "$should_not_contain"; then
        echo "FAIL: Sensitive arguments visible in ps: $ps_output"
        result=1
    fi

    # Check if expected visible args are present (if specified)
    if [ -n "$expected_visible" ] && ! echo "$ps_output" | grep -q "$expected_visible"; then
        echo "INFO: Expected visible args not found: $expected_visible"
        # This might not be a failure, depending on implementation
    fi

    # Linux-specific: check /proc/cmdline
    if [ -r "/proc/$pid/cmdline" ] && [ "$(uname -s)" = "Linux" ]; then
        local cmdline_content
        cmdline_content=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || echo "")

        if [ -n "$should_not_contain" ] && echo "$cmdline_content" | grep -q "$should_not_contain"; then
            echo "FAIL: Sensitive arguments visible in /proc/cmdline: $cmdline_content"
            result=1
        fi
    fi

    if [ $result -eq 0 ]; then
        echo "PASS: Process stealth check passed"
    fi

    return $result
}

# Utility: Start socat with stealth test and return PID
# Usage: start_stealth_socat "listen_port" "test_args"
start_stealth_socat() {
    local port="$1"
    local test_args="$2"
    local timeout="${3:-10}"

    # Start socat in background
    timeout "$timeout" "$SOCAT_BINARY" \
        TCP-LISTEN:"$port",fork,reuseaddr \
        EXEC:'/bin/cat' $test_args &

    local socat_pid=$!

    # Give it a moment to initialize
    sleep 1

    # Verify it's still running
    if ! kill -0 "$socat_pid" 2>/dev/null; then
        echo "Failed to start socat process"
        return 1
    fi

    echo "$socat_pid"
    return 0
}

# Utility: Test functional connectivity while stealth is active
# Usage: test_stealth_connectivity "port" "test_message"
test_stealth_connectivity() {
    local port="$1"
    local test_message="$2"
    local timeout="${3:-5}"

    local result
    result=$(echo "$test_message" | timeout "$timeout" "$SOCAT_BINARY" - TCP-CONNECT:localhost:"$port" 2>/dev/null || echo "")

    if [ "$result" = "$test_message" ]; then
        echo "PASS: Connectivity test successful"
        return 0
    else
        echo "FAIL: Connectivity test failed. Expected: '$test_message', Got: '$result'"
        return 1
    fi
}

# Utility: Clean up test processes
# Usage: cleanup_test_processes PID1 [PID2 ...]
cleanup_test_processes() {
    for pid in "$@"; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            # Give it a moment to die gracefully
            sleep 0.5
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null || true
            fi
            wait "$pid" 2>/dev/null || true
        fi
    done
}

# Utility: Check if stealth functionality is compiled into binary
# Usage: detect_stealth_support "/path/to/socat"
detect_stealth_support() {
    local binary="${1:-./socat}"

    if [ ! -x "$binary" ]; then
        echo "Binary not found or not executable: $binary"
        return 1
    fi

    # Method 1: Check for stealth symbols in binary
    if command -v objdump >/dev/null 2>&1; then
        if objdump -t "$binary" 2>/dev/null | grep -q stealth_hide_arguments; then
            echo "DETECTED: stealth_hide_arguments function found in binary"
            return 0
        fi
    fi

    # Method 2: Check for stealth.o in build directory
    if [ -f "$(dirname "$binary")/stealth.o" ] || [ -f stealth.o ]; then
        echo "DETECTED: stealth.o object file found"
        return 0
    fi

    # Method 3: Check strings in binary for stealth-related content
    if command -v strings >/dev/null 2>&1; then
        if strings "$binary" 2>/dev/null | grep -q "stealth"; then
            echo "DETECTED: stealth-related strings found in binary"
            return 0
        fi
    fi

    echo "UNKNOWN: Cannot definitively detect stealth support"
    return 1
}

# Utility: Platform-specific process name check
# Usage: check_process_name PID "expected_name"
check_process_name() {
    local pid="$1"
    local expected_name="$2"
    local platform

    platform=$(uname -s)

    case "$platform" in
        Linux)
            # Check /proc/PID/comm for process name
            if [ -r "/proc/$pid/comm" ]; then
                local comm_name
                comm_name=$(cat "/proc/$pid/comm" 2>/dev/null | tr -d '\n')
                if [ "$comm_name" = "$expected_name" ]; then
                    echo "PASS: Process name correctly set to '$expected_name'"
                    return 0
                else
                    echo "INFO: Process name is '$comm_name', expected '$expected_name'"
                fi
            fi
            ;;
        Darwin|FreeBSD|OpenBSD|NetBSD)
            # BSD-style systems
            local ps_comm
            ps_comm=$(ps -p "$pid" -o comm= 2>/dev/null | head -1 | tr -d ' ')
            if [ "$ps_comm" = "$expected_name" ]; then
                echo "PASS: Process name correctly set to '$expected_name'"
                return 0
            else
                echo "INFO: Process name is '$ps_comm', expected '$expected_name'"
            fi
            ;;
        *)
            echo "INFO: Process name check not implemented for platform: $platform"
            return 0
            ;;
    esac

    return 1
}

# Utility: Generate a random test string for connectivity tests
# Usage: generate_test_string [length]
generate_test_string() {
    local length="${1:-16}"

    # Use a mix of methods for portability
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex $((length/2)) 2>/dev/null | head -c "$length"
    elif [ -r /dev/urandom ]; then
        tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length" 2>/dev/null
    else
        # Fallback for systems without good random sources
        echo "test_$$_$(date +%N)" | head -c "$length"
    fi
    echo
}

# Utility: Find available port for testing
# Usage: find_available_port [start_port]
find_available_port() {
    local start_port="${1:-12000}"
    local port="$start_port"
    local max_attempts=100

    while [ $max_attempts -gt 0 ]; do
        if ! netstat -an 2>/dev/null | grep -q ":$port "; then
            # Double-check with a quick connection attempt
            if ! timeout 1 bash -c "</dev/tcp/localhost/$port" 2>/dev/null; then
                echo "$port"
                return 0
            fi
        fi
        port=$((port + 1))
        max_attempts=$((max_attempts - 1))
    done

    echo "ERROR: Could not find available port starting from $start_port" >&2
    return 1
}

# Utility: Validate test environment
# Usage: validate_test_environment
validate_test_environment() {
    local errors=0

    # Check for required tools
    local required_tools="ps timeout"
    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "ERROR: Required tool not found: $tool"
            errors=$((errors + 1))
        fi
    done

    # Check for socat binary
    local socat_binary="${SOCAT_BINARY:-./socat}"
    if [ ! -x "$socat_binary" ]; then
        echo "ERROR: socat binary not found or not executable: $socat_binary"
        errors=$((errors + 1))
    fi

    # Check if we can create network connections (for connectivity tests)
    if ! timeout 1 bash -c "</dev/tcp/localhost/22" 2>/dev/null; then
        # This is expected to fail, but tests that TCP is available
        true
    fi

    if [ $errors -eq 0 ]; then
        echo "PASS: Test environment validation successful"
        return 0
    else
        echo "FAIL: Test environment validation failed with $errors errors"
        return 1
    fi
}

# Export functions for use by sourcing scripts
export -f check_process_stealth
export -f start_stealth_socat
export -f test_stealth_connectivity
export -f cleanup_test_processes
export -f detect_stealth_support
export -f check_process_name
export -f generate_test_string
export -f find_available_port
export -f validate_test_environment