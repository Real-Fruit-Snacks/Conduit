# Stealth Testing Framework

This directory contains a comprehensive testing framework for socat's stealth functionality.

## Files

- `test-stealth.sh` - Main stealth test suite
- `test-stealth-integration.sh` - Integration with existing test.sh

## Quick Start

### Run Stealth Tests Only

```bash
# Run with default binary (./socat)
./test-stealth.sh

# Run with specific binary and verbose output
./test-stealth.sh -b /usr/local/bin/socat -v

# Run with custom timeout
./test-stealth.sh -t 30
```

### Integration with Main Test Suite

```bash
# Source the integration script in test.sh
source ./test-stealth-integration.sh

# Then call:
run_stealth_tests ./socat
```

## Test Coverage

The stealth test suite covers:

### Argument Hiding Tests
- **ps command hiding** - Verifies arguments not visible in `ps` output
- **procfs cmdline hiding** - Tests `/proc/PID/cmdline` on Linux
- **Process name consistency** - Checks process name across tools

### Platform-Specific Tests
- **Linux**: Tests `prctl(PR_SET_NAME)` functionality
- **BSD**: Tests `setproctitle()` functionality  
- **Fallback**: Tests `memset()` fallback method

### Integration Tests
- **Functional correctness** - Ensures socat works despite stealth mode
- **Static linking verification** - Validates static builds when requested
- **Binary availability** - Checks socat binary exists and is executable

## Test Architecture

### Test Framework Features
- Color-coded output with pass/fail indicators
- Verbose logging mode for debugging
- Configurable timeouts for process tests
- Platform detection and appropriate test selection
- Comprehensive error reporting and test summaries

### Test Process Flow
1. **Binary Validation** - Verify socat binary exists and has stealth support
2. **Platform Detection** - Identify OS and available stealth methods
3. **Argument Hiding Tests** - Test process inspection tool immunity
4. **Functional Tests** - Verify socat still works correctly
5. **Integration Tests** - Ensure compatibility with main test suite

### Error Handling
- Tests fail gracefully with descriptive error messages
- Process cleanup ensures no zombie processes
- Timeout protection prevents hanging tests
- Platform-specific tests skip gracefully when not applicable

## Expected Behavior

### Successful Stealth Operation
When stealth is working correctly:
- Process arguments should not appear in `ps` output
- `/proc/PID/cmdline` should not show original arguments (Linux)
- Process name should be set to "socat"
- socat functionality should remain unaffected

### Platform Differences
- **Linux**: Uses `prctl(PR_SET_NAME)` + `memset()`
- **FreeBSD/NetBSD/OpenBSD/Darwin**: Uses `setproctitle()` + `memset()`
- **Other Unix**: Uses `memset()` fallback only

### Fallback Behavior
If platform-specific APIs fail:
- Falls back to `memset()` argument clearing
- Function fails silently (operational security)
- socat continues normal operation

## Integration with Build System

The stealth tests can be integrated into the existing build/test pipeline:

```bash
# Add to Makefile test target
test: socat test-stealth
	./test.sh && ./test-stealth.sh

# Or integrate into test.sh directly
source ./test-stealth-integration.sh
run_stealth_tests ./socat
```

## Troubleshooting

### Common Issues

**Test fails with "Binary not found"**
- Ensure socat is compiled: `make socat`
- Check binary path: `./test-stealth.sh -b /path/to/socat`

**Process name tests fail**
- Some platforms may not support process renaming
- Check if `prctl()` or `setproctitle()` are available
- Fallback behavior is still operational

**Permission errors**
- Ensure test script is executable: `chmod +x test-stealth.sh`
- Some `/proc` access may require permissions

### Debug Mode

Run with verbose output to see detailed test execution:

```bash
./test-stealth.sh -v
```

This will show:
- Platform detection results
- Binary analysis output
- Process inspection tool results
- Detailed pass/fail reasons

## Security Considerations

These tests verify operational security features:
- Argument hiding protects sensitive connection details
- Process name masking reduces reconnaissance value
- Functional testing ensures security doesn't break usability

The test framework itself:
- Uses temporary ports to avoid conflicts
- Cleans up test processes automatically
- Does not expose sensitive data in output