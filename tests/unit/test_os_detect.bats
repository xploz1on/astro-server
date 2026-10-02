#!/usr/bin/env bats

load "../test_helper.bash"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "OS detection detects Debian/Ubuntu correctly" {
    cat > "$TEST_TMP_DIR/os-release" << 'EOF'
NAME="Ubuntu"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
ID=ubuntu
ID_LIKE=debian
EOF

    run bash -c "
        source '$LIB_DIR/colors.sh'
        
        # Source with replaced /etc/os-release path
        eval \"\$(sed 's|/etc/os-release|'$TEST_TMP_DIR/os-release'|g' '$LIB_DIR/os_detect.sh')\"
        
        detect_os
        echo \"FAMILY=\$OS_FAMILY PKG=\$PKG_MANAGER SSH=\$SSH_SERVICE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" =~ "FAMILY=debian PKG=apt SSH=ssh" ]]
}

@test "OS detection detects RHEL/Rocky correctly" {
    cat > "$TEST_TMP_DIR/os-release" << 'EOF'
NAME="Rocky Linux"
VERSION="9.3 (Blue Onyx)"
ID=rocky
ID_LIKE="rhel centos fedora"
EOF

    run bash -c "
        source '$LIB_DIR/colors.sh'
        
        eval \"\$(sed 's|/etc/os-release|'$TEST_TMP_DIR/os-release'|g' '$LIB_DIR/os_detect.sh')\"
        
        # Mock command -v for dnf
        command() { if [ \"\$1\" = \"-v\" ] && [ \"\$2\" = \"dnf\" ]; then return 0; fi; return 1; }
        
        detect_os
        echo \"FAMILY=\$OS_FAMILY PKG=\$PKG_MANAGER SSH=\$SSH_SERVICE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" =~ "FAMILY=redhat PKG=dnf SSH=sshd" ]]
}

@test "OS detection detects Arch Linux correctly" {
    cat > "$TEST_TMP_DIR/os-release" << 'EOF'
NAME="Arch Linux"
ID=arch
EOF

    run bash -c "
        source '$LIB_DIR/colors.sh'
        
        eval \"\$(sed 's|/etc/os-release|'$TEST_TMP_DIR/os-release'|g' '$LIB_DIR/os_detect.sh')\"
        
        detect_os
        echo \"FAMILY=\$OS_FAMILY PKG=\$PKG_MANAGER SSH=\$SSH_SERVICE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" =~ "FAMILY=arch PKG=pacman SSH=sshd" ]]
}
