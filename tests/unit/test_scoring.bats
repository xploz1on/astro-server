#!/usr/bin/env bats

load "../test_helper.bash"

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "calculate_security_score evaluates correct score based on mocks" {
    run bash -c "
        source '$LIB_DIR/colors.sh'
        source '$LIB_DIR/scoring.sh'
        
        # Mock sudo and sysctl
        sudo() {
            if [[ \"\$*\" =~ \"PermitRootLogin\" ]]; then return 0; fi
            if [[ \"\$*\" =~ \"PasswordAuthentication\" ]]; then return 1; fi
            if [[ \"\$*\" =~ \"systemctl is-active --quiet fail2ban\" ]]; then return 0; fi
            return 1
        }
        
        command() {
            if [[ \"\$*\" =~ \"fail2ban-client\" ]]; then return 0; fi
            if [[ \"\$*\" =~ \"ufw\" ]]; then return 1; fi
            if [[ \"\$*\" =~ \"firewall-cmd\" ]]; then return 1; fi
            return 1
        }
        
        sysctl() {
            if [[ \"\$1\" == \"net.ipv4.tcp_rfc1337\" ]]; then echo \"= 1\"; fi
            if [[ \"\$1\" == \"kernel.randomize_va_space\" ]]; then echo \"= 2\"; fi
            if [[ \"\$1\" == \"fs.protected_symlinks\" ]]; then echo \"= 1\"; fi
            if [[ \"\$1\" == \"fs.suid_dumpable\" ]]; then echo \"= 0\"; fi
        }
        
        calculate_security_score
    "
    [ "$status" -eq 0 ]
    
    # +15 (root login) 
    # +0 (pw auth) 
    # +15 (f2b) 
    # +0 (fw) 
    # +10 (rfc1337) 
    # +10 (aslr) 
    # +10 (symlinks) 
    # +10 (suid dumpable)
    # Total = 70
    [ "$output" -eq 70 ]
}
