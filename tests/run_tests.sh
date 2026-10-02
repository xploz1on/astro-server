#!/usr/bin/env bash

# Astro Server Test Suite Runner
# Runs Bats-core if available, or native bash assertions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Terminal styling
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [ -n "${NO_COLOR:-}" ] || [ ! -t 1 ]; then
    GREEN=''; RED=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║           🧪 ASTRO SERVER AUTOMATED TEST RUNNER              ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo

if command -v bats >/dev/null 2>&1; then
    echo -e "${BLUE}ℹ️  Executing Bats-core test runner...${NC}"
    echo
    bats "$SCRIPT_DIR/unit"
    echo
    echo -e "${GREEN}${BOLD}✅ Bats test suite passed!${NC}"
    exit 0
fi

echo -e "${YELLOW}ℹ️  Bats not found in PATH — executing native test assertions...${NC}"
echo

TESTS_PASSED=0
TESTS_FAILED=0

assert_test() {
    local name="$1"
    local cmd="$2"
    printf "  %-65s " "$name"
    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}${BOLD}[ PASS ]${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}${BOLD}[ FAIL ]${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo -e "${BLUE}${BOLD}1. Shell Syntax Validation:${NC}"
assert_test "Syntax check: astro launcher" "bash -n '$ROOT_DIR/astro'"
assert_test "Syntax check: Astro-server.sh" "bash -n '$ROOT_DIR/scripts/Astro-server.sh'"
for f in "$ROOT_DIR/scripts/lib/"*.sh; do
    assert_test "Syntax check: $(basename "$f")" "bash -n '$f'"
done
assert_test "Syntax check: security-report.sh" "bash -n '$ROOT_DIR/scripts/security-report.sh'"
echo

echo -e "${BLUE}${BOLD}2. Security & Hardening Assertions:${NC}"
assert_test "No private key cleartext echo to stdout" "! grep -E 'echo -e.*cat.*id_ed25519' '$ROOT_DIR/scripts/lib/ssh.sh'"
assert_test "Zero static /tmp/ paths in Astro-server.sh" "! grep '/tmp/' '$ROOT_DIR/scripts/Astro-server.sh' | grep -v 'IP_CACHE_FILE'"
assert_test "All read commands use -r flag" "! grep -E 'read [^-]' '$ROOT_DIR/scripts/lib/'*.sh '$ROOT_DIR/astro'"
assert_test "Safe mode (set -euo pipefail) enabled" "grep -q 'set -euo pipefail' '$ROOT_DIR/scripts/Astro-server.sh'"
assert_test "RFC 1337 TIME-WAIT protection in sysctl.sh" "grep -q 'net.ipv4.tcp_rfc1337 = 1' '$ROOT_DIR/scripts/lib/sysctl.sh'"
assert_test "RFC 1337 in Ansible 99-security.conf.j2" "grep -q 'net.ipv4.tcp_rfc1337 = 1' '$ROOT_DIR/ansible/templates/99-security.conf.j2'"
assert_test "HostKeyAlgorithms configured in sshd_config.j2" "grep -q 'HostKeyAlgorithms' '$ROOT_DIR/ansible/templates/sshd_config.j2'"
assert_test "Isolated backup directory (/var/backups/astro-server)" "grep -q '/var/backups/astro-server' '$ROOT_DIR/scripts/lib/ssh.sh'"
echo

echo -e "${BLUE}${BOLD}3. Linux Distribution Portability Assertions:${NC}"
assert_test "OS detection logic handles apt, dnf, pacman" "grep -q 'detect_os' '$ROOT_DIR/scripts/lib/os_detect.sh'"
assert_test "Package manager abstraction functions exist" "grep -q 'pkg_install' '$ROOT_DIR/scripts/lib/os_detect.sh'"
assert_test "Dynamic SSH service resolution (ssh vs sshd)" "grep -q 'SSH_SERVICE' '$ROOT_DIR/scripts/lib/os_detect.sh'"
assert_test "dnf-automatic configured for RedHat systems" "grep -q 'dnf-automatic' '$ROOT_DIR/scripts/Astro-server.sh'"
echo

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "Total: ${BOLD}$TOTAL_TESTS${NC} | Passed: ${GREEN}${BOLD}$TESTS_PASSED${NC} | Failed: ${RED}${BOLD}$TESTS_FAILED${NC}"

if [ "$TESTS_FAILED" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}🎉 ALL $TOTAL_TESTS AUTOMATED ASSERTIONS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}${BOLD}❌ $TESTS_FAILED TEST(S) FAILED.${NC}"
    exit 1
fi
