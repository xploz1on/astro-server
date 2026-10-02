# 📈 Improvement Planner: Architecture, Quality & Roadmap Analysis

**Date:** 2026-09-04  
**Analyst:** Improvement Planner Agent  
**Scope:** Whole codebase structure, roadmap alignment, refactoring plans, metrics  
**Status:** COMPLETE  

---

## Executive Summary

The Astro Server Security Toolkit is functionally strong with an appealing interactive terminal CLI and robust default cryptographic parameters. However, the repository has reached the limits of single-file script scripting: `scripts/Astro-server.sh` is a 908-line monolith containing mixed responsibilities (distro checks, UX, SSH generation, firewall logic, sysctl writing, and unattended-upgrades config).

To scale towards v1.1.0 and enterprise adoption, Astro Server needs:
1. **Modular Architecture:** Extracting self-contained modules into `lib/` or `modules/`.
2. **Automated Testing & CI:** Implementing Bats-core test suites and multi-distro container testing.
3. **Unified Configuration Layer:** Eliminating drift between Ansible playbooks and standalone bash scripts.

---

## Key Metrics

| Metric | Current Baseline | Target (v1.1.0) | Gap |
|--------|------------------|-----------------|-----|
| Max Script Size | 908 lines (`Astro-server.sh`) | < 250 lines per module | -658 lines |
| Automated Test Coverage | 0% (0 unit/integration tests) | > 80% (Bats / Container matrix) | +80% |
| Distributions Verified | 2 (Ubuntu, Debian) | 6+ (Ubuntu, Debian, RHEL, Rocky, Fedora, Arch) | +4 distros |
| CI/CD Automated Checks | GitHub Actions for linting only | Full matrix lint + ShellCheck + Bats | Modern CI |
| Open Critical Vulnerabilities | 1 (SEC-001 private key leak) | 0 | -1 |

---

## Top 5 Improvement Opportunities

### 1. [PLAN-001] Script Modularization (Phase 1 Refactoring)
- **Current:** `scripts/Astro-server.sh` handles all hardening phases in 908 sequential lines.
- **Proposed Structure:**
  ```text
  scripts/
  ├── astro-harden.sh (thin orchestrator, ~100 lines)
  └── lib/
      ├── colors.sh
      ├── os_detect.sh
      ├── ssh.sh
      ├── firewall.sh
      ├── sysctl.sh
      ├── fail2ban.sh
      └── updates.sh
  ```
- **Benefits:** Clean separation of concerns, testable discrete functions, easier multi-distribution adaptations.

### 2. [PLAN-002] Automated Testing Framework with Bats-core
- **Action:** Introduce Bats-core in `tests/`:
  - `tests/unit/test_os_detect.bats`
  - `tests/unit/test_sysctl.bats`
  - `tests/unit/test_ssh_config.bats`
  - `tests/integration/test_hardening_dry_run.bats`
- **Docker Matrix:** Run tests in Docker containers (`ubuntu:22.04`, `debian:12`, `rockylinux:9`, `fedora:39`).

### 3. [PLAN-003] Configuration Drift Reconciliation
- **Issue:** The standalone bash script and the Ansible role maintain independent copies of sysctl parameters and SSH configurations.
- **Solution:** Introduce a single source of truth (e.g. `configs/hardening-baseline.conf` or structured YAML) from which both Ansible templates and shell scripts read parameters.

### 4. [PLAN-004] Automated Rollback & Snapshot Command
- **Current:** Backups are placed in `/etc/ssh/*.backup.*` without an automated rollback command.
- **Solution:** Implement `./astro rollback` that tracks backup manifests and can restore SSH and firewall configs with a single command if locked out.

### 5. [PLAN-005] CIS Benchmark Compliance Scanner Module
- **Current:** Hardens systems, but cannot audit existing non-hardened systems against CIS controls without applying changes.
- **Solution:** Implement `./astro audit --benchmark cis-linux-l1` to provide a pass/fail compliance score before and after hardening.

---

## Roadmap Alignment (v1.0.1 Patch & v1.1.0 Minor)

- **v1.0.1 (Immediate Emergency Patch):**
  - Fix SEC-001 (remove private key echo to stdout).
  - Add `set -euo pipefail` to `Astro-server.sh`.
  - Fix `/tmp` static paths.
  - Fix `read -rp` across all scripts.
- **v1.1.0 (Next Minor Milestone):**
  - Modularize `Astro-server.sh` into `lib/`.
  - Implement distribution abstraction (RHEL/Rocky/Fedora/Arch support).
  - Add Bats test suite and GitHub Actions matrix.
