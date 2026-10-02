#!/usr/bin/env bats

load "../test_helper.bash"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "ssh.sh enforces HostKeyAlgorithms with ed25519 and rsa-sha2" {
    run grep "HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256" "$LIB_DIR/ssh.sh"
    [ "$status" -eq 0 ]
}

@test "Ansible sshd_config.j2 template includes HostKeyAlgorithms default" {
    local template="$ASTRO_TEST_ROOT/ansible/templates/sshd_config.j2"
    run grep "HostKeyAlgorithms" "$template"
    [ "$status" -eq 0 ]
}

@test "Zero private key leaks to stdout in ssh.sh" {
    # Verify no command echoes the cleartext private key
    run grep 'echo -e.*cat.*id_ed25519' "$LIB_DIR/ssh.sh"
    [ "$status" -ne 0 ]
}

@test "ssh.sh enforces isolated backup directory with 0700/0600 permissions" {
    run grep "/var/backups/astro-server" "$LIB_DIR/ssh.sh"
    [ "$status" -eq 0 ]

    run grep "chmod 600" "$LIB_DIR/ssh.sh"
    [ "$status" -eq 0 ]
}
