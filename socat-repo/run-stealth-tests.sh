#!/usr/bin/env bash
# source: run-stealth-tests.sh
# Master test runner for stealth functionality
# Integrates all stealth testing components and provides various test modes

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOCAT_BINARY="${SOCAT_BINARY:-$SCRIPT_DIR/socat}"
VERBOSE=${VERBOSE:-0}
QUICK_MODE=${QUICK_MODE:-0}

# Color output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[PASS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [TEST_MODE]

Master test runner for socat stealth functionality.

OPTIONS:
    -b BINARY    Path to socat binary (default: ./socat)
    -v           Verbose output
    -q           Quick mode (essential tests only)
    -h           Show this help

TEST_MODES:
    full         Run complete test suite (default)
    quick        Run essential tests only
    integration  Test integration with main test.sh
    utils        Test utility functions only
    validate     Validate test environment only

ENVIRONMENT:
    SOCAT_BINARY    Path to socat binary
    VERBOSE         Enable verbose output (0/1)
    QUICK_MODE      Enable quick mode (0/1)

EXAMPLES:
    # Run full test suite
    $0

    # Quick test with verbose output
    $0 -v -q

    # Test specific binary
    $0 -b /usr/bin/socat full

    # Validate environment only
    $0 validate

EOF
}

# Parse command line
while getopts "b:vqh" opt; do
    case $opt in
        b) SOCAT_BINARY="$OPTARG" ;;
        v) VERBOSE=1 ;;
        q) QUICK_MODE=1 ;;
        h) show_help; exit 0 ;;
        \?) error "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

shift $((OPTIND-1))
TEST_MODE="${1:-full}"

# Export settings for sub-scripts
export SOCAT_BINARY VERBOSE QUICK_MODE

# Test modes
run_validation_only() {
    info "Running environment validation only..."

    # Source utilities and run validation
    if [ -f "$SCRIPT_DIR/test-stealth-utils.sh" ]; then
        source "$SCRIPT_DIR/test-stealth-utils.sh"
        if validate_test_environment; then
            success "Environment validation passed"
            return 0
        else
            error "Environment validation failed"
            return 1
        fi
    else
        error "test-stealth-utils.sh not found"
        return 1
    fi
}

run_utils_test() {
    info "Testing utility functions..."

    if [ ! -f "$SCRIPT_DIR/test-stealth-utils.sh" ]; then
        error "test-stealth-utils.sh not found"
        return 1
    fi

    # Test utility functions
    source "$SCRIPT_DIR/test-stealth-utils.sh"

    local errors=0

    # Test port finding
    info "Testing port finding utility..."
    local test_port
    test_port=$(find_available_port 15000)
    if [ $? -eq 0 ] && [ -n "$test_port" ]; then
        success "Port finding utility works: found port $test_port"
    else
        error "Port finding utility failed"
        errors=$((errors + 1))
    fi

    # Test string generation
    info "Testing string generation utility..."
    local test_string
    test_string=$(generate_test_string 10)
    if [ ${#test_string} -eq 10 ]; then
        success "String generation utility works: '$test_string'"
    else
        error "String generation utility failed: got '${test_string}' (length ${#test_string})"
        errors=$((errors + 1))
    fi

    # Test stealth detection (even if binary doesn't exist)
    info "Testing stealth detection utility..."
    detect_stealth_support "$SOCAT_BINARY" >/dev/null 2>&1
    success "Stealth detection utility runs without error"

    if [ $errors -eq 0 ]; then
        success "All utility function tests passed"
        return 0
    else
        error "$errors utility function tests failed"
        return 1
    fi
}

run_integration_test() {
    info "Testing integration with main test suite..."

    if [ ! -f "$SCRIPT_DIR/test-stealth-integration.sh" ]; then
        error "test-stealth-integration.sh not found"
        return 1
    fi

    # Test the integration script
    if [ -x "$SCRIPT_DIR/test-stealth-integration.sh" ]; then
        # Test quick check function
        source "$SCRIPT_DIR/test-stealth-integration.sh"
        quick_stealth_check "$SOCAT_BINARY"
        success "Integration script functions work"
        return 0
    else
        error "test-stealth-integration.sh not executable"
        return 1
    fi
}

run_quick_test() {
    info "Running quick stealth tests..."

    if [ ! -f "$SCRIPT_DIR/test-stealth.sh" ]; then
        error "test-stealth.sh not found"
        return 1
    fi

    # Run subset of tests quickly
    local quick_args="-t 5"
    if [ "$VERBOSE" -eq 1 ]; then
        quick_args="$quick_args -v"
    fi

    if [ -x "$SCRIPT_DIR/test-stealth.sh" ]; then
        info "Running essential stealth functionality tests..."
        "$SCRIPT_DIR/test-stealth.sh" $quick_args -b "$SOCAT_BINARY"
        return $?
    else
        error "test-stealth.sh not executable"
        return 1
    fi
}

run_full_test() {
    info "Running complete stealth test suite..."

    local full_args=""
    if [ "$VERBOSE" -eq 1 ]; then
        full_args="-v"
    fi

    # Run all test components
    local errors=0

    # 1. Environment validation
    info "Step 1/4: Environment validation"
    run_validation_only || errors=$((errors + 1))

    # 2. Utility functions
    info "Step 2/4: Utility functions"
    run_utils_test || errors=$((errors + 1))

    # 3. Integration test
    info "Step 3/4: Integration test"
    run_integration_test || errors=$((errors + 1))

    # 4. Main stealth tests
    info "Step 4/4: Main stealth functionality tests"
    if [ -f "$SCRIPT_DIR/test-stealth.sh" ] && [ -x "$SCRIPT_DIR/test-stealth.sh" ]; then
        "$SCRIPT_DIR/test-stealth.sh" $full_args -b "$SOCAT_BINARY" || errors=$((errors + 1))
    else
        error "test-stealth.sh not found or not executable"
        errors=$((errors + 1))
    fi

    # Summary
    echo
    if [ $errors -eq 0 ]; then
        success "All stealth tests completed successfully!"
        return 0
    else
        error "$errors test component(s) failed"
        return 1
    fi
}

# Ensure we're in the right directory
cd "$SCRIPT_DIR" || {
    error "Cannot change to script directory: $SCRIPT_DIR"
    exit 1
}

# Main execution
case "$TEST_MODE" in
    validate)
        run_validation_only
        ;;
    utils)
        run_utils_test
        ;;
    integration)
        run_integration_test
        ;;
    quick)
        run_quick_test
        ;;
    full)
        if [ "$QUICK_MODE" -eq 1 ]; then
            run_quick_test
        else
            run_full_test
        fi
        ;;
    *)
        error "Unknown test mode: $TEST_MODE"
        echo
        show_help
        exit 1
        ;;
esac