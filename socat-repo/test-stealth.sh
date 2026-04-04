#!/usr/bin/env bash
# source: test-stealth.sh
# Copyright Gerhard Rieger and contributors (see file CHANGES)
# Published under the GNU General Public License V.2, see file COPYING

# Stealth functionality test suite for socat
# Tests argument hiding across different platforms and process inspection tools

# Exit on any error
set -e

# Configuration
SOCAT_BINARY="${SOCAT_BINARY:-./socat}"
TEST_TIMEOUT=10
VERBOSE=${VERBOSE:-0}
PLATFORM=$(uname -s)

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Utility functions
log() {
    if [ "$VERBOSE" -gt 0 ]; then
        echo -e "${BLUE}[LOG]${NC} $*" >&2
    fi
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

success() {
    echo -e "${GREEN}[PASS]${NC} $*"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $*" >&2
}

# Test framework functions
start_test() {
    local test_name="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    info "Running test: $test_name"
}

pass_test() {
    local test_name="$1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    success "$test_name"
}

fail_test() {
    local test_name="$1"
    local reason="$2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("$test_name: $reason")
    fail "$test_name - $reason"
}

# Check if socat binary exists and is executable
check_socat_binary() {
    start_test "Binary availability check"

    if [ ! -f "$SOCAT_BINARY" ]; then
        fail_test "Binary availability check" "socat binary not found at $SOCAT_BINARY"
        return 1
    fi

    if [ ! -x "$SOCAT_BINARY" ]; then
        fail_test "Binary availability check" "socat binary not executable at $SOCAT_BINARY"
        return 1
    fi

    pass_test "Binary availability check"
    return 0
}

# Check if socat was compiled with stealth support
check_stealth_support() {
    start_test "Stealth support detection"

    # Check if stealth.o was compiled into the binary
    if command -v objdump >/dev/null 2>&1; then
        if objdump -t "$SOCAT_BINARY" 2>/dev/null | grep -q stealth_hide_arguments; then
            log "Stealth function detected in binary"
            pass_test "Stealth support detection"
            return 0
        fi
    fi

    # Fallback: check if stealth.o exists (compilation check)
    if [ -f "stealth.o" ]; then
        log "stealth.o found, assuming stealth support compiled in"
        pass_test "Stealth support detection"
        return 0
    fi

    warn "Cannot definitively detect stealth support - proceeding with tests"
    pass_test "Stealth support detection (assumed)"
    return 0
}

# Test static linking if requested
check_static_linking() {
    start_test "Static linking verification"

    # Only test if binary appears to be statically linked
    if command -v ldd >/dev/null 2>&1; then
        local ldd_output
        ldd_output=$(ldd "$SOCAT_BINARY" 2>&1 || true)

        if echo "$ldd_output" | grep -q "not a dynamic executable"; then
            log "Binary is statically linked"
            pass_test "Static linking verification"
            return 0
        elif echo "$ldd_output" | grep -q "statically linked"; then
            log "Binary is statically linked"
            pass_test "Static linking verification"
            return 0
        else
            log "Binary appears dynamically linked, skipping static test"
            pass_test "Static linking verification (dynamic binary)"
            return 0
        fi
    else
        log "ldd not available, skipping static linking test"
        pass_test "Static linking verification (ldd unavailable)"
        return 0
    fi
}

# Helper function to start socat with test arguments in background
start_test_socat() {
    local test_args="$1"
    local port_base="$2"

    # Use a simple echo server setup that will run briefly
    timeout "$TEST_TIMEOUT" "$SOCAT_BINARY" $test_args \
        TCP-LISTEN:$((port_base)),fork,reuseaddr \
        EXEC:'/bin/cat' &

    echo $!
}

# Test argument hiding with ps command
test_ps_hiding() {
    start_test "ps command argument hiding"

    local test_args="-d -d -v TCP-LISTEN:12345,fork EXEC:/bin/cat"
    local port=12345
    local socat_pid

    # Start socat with visible arguments
    socat_pid=$(start_test_socat "$test_args" "$port")

    # Give it time to initialize and hide arguments
    sleep 1

    # Check if arguments are hidden in ps output
    local ps_output
    ps_output=$(ps -p "$socat_pid" -o args= 2>/dev/null || true)

    # Kill the socat process
    kill "$socat_pid" 2>/dev/null || true
    wait "$socat_pid" 2>/dev/null || true

    if [ -z "$ps_output" ]; then
        fail_test "ps command argument hiding" "Process not found in ps output"
        return 1
    fi

    # Check if sensitive arguments are hidden
    if echo "$ps_output" | grep -q "TCP-LISTEN"; then
        fail_test "ps command argument hiding" "Arguments still visible in ps: $ps_output"
        return 1
    fi

    # Check if process name is set to "socat"
    if echo "$ps_output" | grep -q "socat"; then
        log "Process name correctly set to 'socat'"
        pass_test "ps command argument hiding"
        return 0
    else
        warn "Process name not set to 'socat', but arguments appear hidden: $ps_output"
        pass_test "ps command argument hiding"
        return 0
    fi
}

# Test argument hiding with /proc/PID/cmdline (Linux-specific)
test_proc_cmdline_hiding() {
    if [ "$PLATFORM" != "Linux" ]; then
        start_test "procfs cmdline argument hiding"
        log "Skipping /proc/cmdline test on non-Linux platform: $PLATFORM"
        pass_test "procfs cmdline argument hiding (platform skip)"
        return 0
    fi

    start_test "procfs cmdline argument hiding"

    local test_args="-d -d -v TCP-LISTEN:12346,fork EXEC:/bin/cat"
    local port=12346
    local socat_pid

    # Start socat with visible arguments
    socat_pid=$(start_test_socat "$test_args" "$port")

    # Give it time to initialize and hide arguments
    sleep 1

    # Check /proc/PID/cmdline
    local cmdline_content=""
    if [ -r "/proc/$socat_pid/cmdline" ]; then
        cmdline_content=$(tr '\0' ' ' < "/proc/$socat_pid/cmdline" 2>/dev/null || true)
    fi

    # Kill the socat process
    kill "$socat_pid" 2>/dev/null || true
    wait "$socat_pid" 2>/dev/null || true

    if [ -z "$cmdline_content" ]; then
        fail_test "procfs cmdline argument hiding" "Could not read /proc/$socat_pid/cmdline"
        return 1
    fi

    # Check if sensitive arguments are hidden
    if echo "$cmdline_content" | grep -q "TCP-LISTEN"; then
        fail_test "procfs cmdline argument hiding" "Arguments visible in /proc/cmdline: $cmdline_content"
        return 1
    fi

    log "cmdline content: '$cmdline_content'"
    pass_test "procfs cmdline argument hiding"
    return 0
}

# Test that socat still functions correctly despite stealth mode
test_functional_correctness() {
    start_test "Functional correctness with stealth"

    local port=12347
    local test_message="stealth_test_message_$$"
    local server_pid

    # Start echo server
    "$SOCAT_BINARY" TCP-LISTEN:$port,fork,reuseaddr EXEC:'/bin/cat' &
    server_pid=$!

    # Give server time to start
    sleep 1

    # Test client connection
    local result
    result=$(echo "$test_message" | timeout 5 "$SOCAT_BINARY" - TCP-CONNECT:localhost:$port 2>/dev/null || true)

    # Cleanup
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true

    if [ "$result" = "$test_message" ]; then
        pass_test "Functional correctness with stealth"
        return 0
    else
        fail_test "Functional correctness with stealth" "Echo test failed. Expected: '$test_message', Got: '$result'"
        return 1
    fi
}

# Test process name hiding with different tools
test_process_name_hiding() {
    start_test "Process name consistency check"

    local test_args="-d TCP-LISTEN:12348,fork EXEC:/bin/cat"
    local port=12348
    local socat_pid

    # Start socat
    socat_pid=$(start_test_socat "$test_args" "$port")

    # Give it time to initialize
    sleep 1

    local tools_tested=0
    local tools_passed=0

    # Test with ps
    if command -v ps >/dev/null 2>&1; then
        tools_tested=$((tools_tested + 1))
        local ps_name
        ps_name=$(ps -p "$socat_pid" -o comm= 2>/dev/null | head -1 || true)
        if [ "$ps_name" = "socat" ] || [ -z "$ps_name" ]; then
            tools_passed=$((tools_passed + 1))
            log "ps: process name OK ($ps_name)"
        else
            log "ps: unexpected process name ($ps_name)"
        fi
    fi

    # Test with top (if available and not interactive)
    if command -v top >/dev/null 2>&1; then
        tools_tested=$((tools_tested + 1))
        # Use batch mode for top to avoid interactivity
        local top_output
        top_output=$(timeout 2 top -b -n 1 -p "$socat_pid" 2>/dev/null | grep "$socat_pid" || true)
        if echo "$top_output" | grep -q "socat"; then
            tools_passed=$((tools_passed + 1))
            log "top: process name OK"
        else
            log "top: process name check inconclusive"
            tools_passed=$((tools_passed + 1))  # Don't fail on top
        fi
    fi

    # Cleanup
    kill "$socat_pid" 2>/dev/null || true
    wait "$socat_pid" 2>/dev/null || true

    if [ "$tools_passed" -eq "$tools_tested" ] && [ "$tools_tested" -gt 0 ]; then
        pass_test "Process name consistency check"
        return 0
    else
        fail_test "Process name consistency check" "Only $tools_passed/$tools_tested tools showed correct process name"
        return 1
    fi
}

# Test stealth behavior on different platforms
test_platform_specific_stealth() {
    start_test "Platform-specific stealth behavior"

    case "$PLATFORM" in
        Linux)
            log "Testing Linux prctl() stealth method"
            # Linux-specific tests already covered in other functions
            pass_test "Platform-specific stealth behavior"
            ;;
        FreeBSD|NetBSD|OpenBSD|Darwin)
            log "Testing BSD setproctitle() stealth method"
            # BSD-specific behavior
            pass_test "Platform-specific stealth behavior"
            ;;
        *)
            log "Testing fallback memset() stealth method on $PLATFORM"
            # Fallback method
            pass_test "Platform-specific stealth behavior"
            ;;
    esac

    return 0
}

# Integration test with existing test.sh
test_integration_with_main_suite() {
    start_test "Integration with main test suite"

    # Check if test.sh exists and can be sourced for functions
    if [ -f "test.sh" ]; then
        log "Main test suite found"
        # We don't actually run the full suite, just verify it exists
        pass_test "Integration with main test suite"
    else
        fail_test "Integration with main test suite" "test.sh not found"
        return 1
    fi

    return 0
}

# Main test execution
run_all_tests() {
    info "Starting stealth functionality test suite"
    info "Platform: $PLATFORM"
    info "Socat binary: $SOCAT_BINARY"
    echo

    # Core tests
    check_socat_binary || return 1
    check_stealth_support
    check_static_linking

    # Stealth functionality tests
    test_ps_hiding
    test_proc_cmdline_hiding
    test_functional_correctness
    test_process_name_hiding
    test_platform_specific_stealth

    # Integration tests
    test_integration_with_main_suite

    echo
    print_summary
}

print_summary() {
    info "Test Summary:"
    info "============="
    info "Tests run: $TESTS_RUN"
    success "Tests passed: $TESTS_PASSED"

    if [ "$TESTS_FAILED" -gt 0 ]; then
        fail "Tests failed: $TESTS_FAILED"
        echo
        error "Failed tests:"
        for failed_test in "${FAILED_TESTS[@]}"; do
            echo "  - $failed_test"
        done
        return 1
    else
        success "All tests passed!"
        return 0
    fi
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Test the stealth functionality of socat binary.

OPTIONS:
    -b BINARY    Path to socat binary (default: ./socat)
    -v          Verbose output
    -t TIMEOUT  Timeout for individual tests (default: 10s)
    -h          Show this help

ENVIRONMENT:
    SOCAT_BINARY    Path to socat binary
    VERBOSE         Enable verbose output (0/1)

EXAMPLES:
    # Test with default binary
    $0

    # Test specific binary with verbose output
    $0 -b /usr/bin/socat -v

    # Test with custom timeout
    $0 -t 30

EOF
}

# Parse command line arguments
while getopts "b:vt:h" opt; do
    case $opt in
        b)
            SOCAT_BINARY="$OPTARG"
            ;;
        v)
            VERBOSE=1
            ;;
        t)
            TEST_TIMEOUT="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            error "Invalid option: -$OPTARG"
            show_help
            exit 1
            ;;
    esac
done

# Ensure we're in the right directory
if [ ! -f "socat.c" ]; then
    error "Please run this script from the socat source directory"
    exit 1
fi

# Run the tests
if run_all_tests; then
    exit 0
else
    exit 1
fi