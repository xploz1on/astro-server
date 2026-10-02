#!/usr/bin/env bash
# tests/test_helper.bash — shared setup/teardown for all Bats suites

export ASTRO_TEST_ROOT
ASTRO_TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPTS_DIR="$ASTRO_TEST_ROOT/scripts"
export LIB_DIR="$SCRIPTS_DIR/lib"

# Create a fresh temp directory for each test
setup_test_env() {
    export TEST_TMP_DIR
    TEST_TMP_DIR=$(mktemp -d -t astro-test-XXXXXX)
    # Provide a fake /etc/os-release inside the temp dir by default (Ubuntu)
    cat > "$TEST_TMP_DIR/os-release" << 'EOF'
NAME="Ubuntu"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
ID=ubuntu
ID_LIKE=debian
EOF
}

teardown_test_env() {
    if [ -n "${TEST_TMP_DIR:-}" ] && [ -d "$TEST_TMP_DIR" ]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Source a lib module with colors stub so tests never need a terminal
source_lib() {
    local mod="$1"
    # Provide stub colors so sourced modules don't break without a terminal
    RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' WHITE='' BOLD='' NC=''
    # shellcheck source=/dev/null
    source "$LIB_DIR/${mod}.sh"
}
