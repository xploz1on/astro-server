# 🤝 Contributing to Astro Server

We love your input! We want to make contributing to Astro Server as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## 🚀 Quick Start for Contributors

1. **Fork the repository**
2. **Create your feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Test your changes** thoroughly
4. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
5. **Push to the branch** (`git push origin feature/AmazingFeature`)
6. **Open a Pull Request**

## 🛡️ Security-First Development

Since this is a security tool, we have strict requirements:

### Security Review Process
- All security-related changes require review by at least 2 maintainers
- New security features must include threat model documentation
- Configuration changes must be tested in isolated environments
- Never commit credentials, keys, or sensitive information

### Testing Requirements
- All scripts must pass shellcheck
- Security configurations must be tested on clean systems
- Ansible playbooks must pass ansible-lint
- Include both positive and negative test cases

## 📋 Development Guidelines

### Code Style

#### Shell Scripts
```bash
#!/bin/bash
# Use strict mode
set -euo pipefail

# Use meaningful variable names
SECURITY_PROFILE="aggressive"
SSH_CONFIG_PATH="/etc/ssh/sshd_config"

# Comment complex logic
# This function validates SSH configuration before applying
validate_ssh_config() {
    local config_file="$1"
    sshd -t -f "$config_file"
}
```

#### Ansible Playbooks
```yaml
---
# Use descriptive task names
- name: Apply SSH hardening configuration with validation
  template:
    src: sshd_config.j2
    dest: /etc/ssh/sshd_config
    backup: yes
    validate: 'sshd -t -f %s'
  notify: restart ssh
```

### Documentation Standards
- Every function must have a comment explaining its purpose
- Complex security configurations need explanation comments
- All user-facing features need documentation updates
- Include examples for new features

### Commit Message Format
```
type(scope): brief description

Detailed explanation of what changed and why.

- Include bullet points for multiple changes
- Reference issues with #123
- Mention breaking changes

Closes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `security`

## 🐛 Bug Reports

Great bug reports tend to have:

- **Quick summary** and/or background
- **Steps to reproduce** - be specific!
- **What you expected** would happen
- **What actually happens**
- **System information** (OS, version, etc.)
- **Security context** (if applicable)

### Bug Report Template
```markdown
## Bug Description
Brief description of the issue

## Environment
- OS: Ubuntu 22.04 LTS
- Astro Server Version: 1.0.0
- Installation Method: Git clone / Package / etc.

## Steps to Reproduce
1. Run `./astro harden`
2. Select profile 'aggressive'
3. See error

## Expected Behavior
SSH should be hardened successfully

## Actual Behavior
Script fails with permission error

## Additional Context
- Running as non-root user with sudo
- Fresh Ubuntu installation
- No custom SSH configuration

## Security Impact
- [ ] This could expose systems to attack
- [ ] This prevents security hardening
- [ ] This is a usability issue only
```

## 💡 Feature Requests

We track feature requests as GitHub issues. Great feature requests include:

- **Clear use case** - why is this needed?
- **Security implications** - how does this improve security?
- **Implementation ideas** - any thoughts on how to build it?
- **Compatibility considerations** - what systems should this support?

### Feature Request Template
```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed? What problem does it solve?

## Security Benefits
How does this improve server security?

## Proposed Implementation
Any ideas on how this could be implemented?

## Compatibility
- [ ] Should work on all supported distributions
- [ ] Requires new dependencies
- [ ] Breaking change to existing functionality

## Additional Context
Any other relevant information
```

## 🔧 Development Areas

We especially welcome contributions in these areas:

### 🐧 Multi-Distribution Support
- **Fedora/RHEL** - Package management, service configuration
- **Arch Linux** - Pacman integration, systemd services
- **Alpine Linux** - OpenRC services, apk packages
- **openSUSE** - Zypper integration, firewall configuration

### 🤖 Ansible Enhancement
- **Role Development** - Modular security roles
- **Inventory Management** - Dynamic inventory scripts
- **Testing Framework** - Molecule testing for roles
- **Documentation** - Ansible-specific guides

### 🛡️ Security Features
- **Compliance Frameworks** - CIS benchmarks, NIST guidelines
- **Container Security** - Docker/Podman hardening
- **Monitoring Integration** - Prometheus, Grafana, ELK
- **Threat Intelligence** - IP reputation, threat feeds

### 📊 Reporting & Monitoring
- **Dashboard Development** - Web-based management interface
- **API Development** - RESTful API for automation
- **Mobile Support** - Mobile-friendly interfaces
- **Integration** - Third-party tool integrations

## 🧪 Testing

### Local Testing
```bash
# Run shellcheck on all scripts
find . -name "*.sh" -exec shellcheck {} \;

# Test Ansible playbooks
ansible-lint ansible/playbooks/*.yml

# Run security tests
./tests/run-security-tests.sh

# Test on different distributions
./tests/test-distributions.sh
```

### Test Environments
- Use virtual machines or containers for testing
- Never test destructive changes on production systems
- Test both successful and failure scenarios
- Verify rollback procedures work correctly

### Required Tests for New Features
- **Unit tests** for individual functions
- **Integration tests** for complete workflows
- **Security tests** to verify hardening effectiveness
- **Compatibility tests** across supported distributions

## 📚 Documentation

### Types of Documentation Needed
- **User Guides** - How to use features
- **Administrator Guides** - Advanced configuration
- **Developer Guides** - Contributing and extending
- **Security Guides** - Understanding the security model

### Documentation Standards
- Use clear, concise language
- Include practical examples
- Provide troubleshooting sections
- Keep security implications in mind
- Update relevant docs with code changes

## 🏷️ Release Process

### Version Numbering
We use [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality
- **PATCH** version for backwards-compatible bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Security review completed
- [ ] Changelog updated
- [ ] Version numbers updated
- [ ] Release notes prepared

## 🛡️ Security Vulnerability Reporting

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: dp@astro-tech.cloud

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We'll acknowledge receipt within 24 hours and provide a detailed response within 72 hours.

## 📞 Getting Help

- **Documentation**: Check the `docs/` directory
- **Issues**: Search existing GitHub issues
- **Discussions**: Use GitHub Discussions for questions
- **Chat**: Join our community chat (link in README)

## 🎯 Maintainer Responsibilities

### Code Review Guidelines
- Focus on security implications
- Verify testing completeness
- Check documentation updates
- Ensure compatibility across distributions
- Validate performance impact

### Merge Criteria
- [ ] Passes all automated tests
- [ ] Has appropriate documentation
- [ ] Follows coding standards
- [ ] Includes security considerations
- [ ] Has been tested by contributor

## 🏆 Recognition

Contributors will be:
- Listed in the GitHub Contributors page
- Mentioned in release notes for significant contributions
- Invited to join the maintainer team for sustained contributions
- Featured in project communications

## 📄 License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

**Thank you for helping make server security accessible to everyone!** 🚀🛡️

*Questions? Feel free to reach out via GitHub issues or discussions.*
