#!/usr/bin/env bats

load "../test_helper.bash"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "sysctl.sh contains RFC 1337 and protected regular/FIFO parameters" {
    run grep "net.ipv4.tcp_rfc1337 = 1" "$LIB_DIR/sysctl.sh"
    [ "$status" -eq 0 ]

    run grep "fs.protected_fifos = 2" "$LIB_DIR/sysctl.sh"
    [ "$status" -eq 0 ]

    run grep "fs.protected_regular = 2" "$LIB_DIR/sysctl.sh"
    [ "$status" -eq 0 ]

    run grep "net.ipv4.conf.all.log_martians = 1" "$LIB_DIR/sysctl.sh"
    [ "$status" -eq 0 ]
}

@test "sysctl.sh defaults net.ipv4.icmp_echo_ignore_all to 0" {
    run grep "net.ipv4.icmp_echo_ignore_all = 0" "$LIB_DIR/sysctl.sh"
    [ "$status" -eq 0 ]
}

@test "Ansible sysctl template contains RFC 1337 and protected parameters" {
    local template="$ASTRO_TEST_ROOT/ansible/templates/99-security.conf.j2"
    run grep "net.ipv4.tcp_rfc1337 = 1" "$template"
    [ "$status" -eq 0 ]

    run grep "fs.protected_fifos = 2" "$template"
    [ "$status" -eq 0 ]
}
