# Astro Server TODO

## v1.2.0 Next Steps
- [ ] **PLAN-006: Distribution & Auto-update**
  - Implement a zero-dependency deployment model.
  - Create a `curl | bash` installer that downloads the latest release tarball and installs it to `/opt/astro-server`.
  - Symlink `/opt/astro-server/astro` to `/usr/local/bin/astro`.
  - Update `./astro update` to support downloading the tarball instead of requiring git pull.
- [ ] **PLAN-005: CIS Linux Benchmark Level 1**
  - Create an automated scoring and auditing capability.
  - Command: `./astro audit --benchmark cis-linux-l1`.

## v1.3.0 Roadmap
- [ ] **Container Hardening**: Add security profiles for Docker and Podman daemon configuration.
- [ ] **Agentic Review Enhancements**: Add LLM integration to allow agents to automatically propose pull requests.
