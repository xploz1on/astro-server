# 🤖 Astro Server — Agent Directory

This directory contains AI agent definitions for the **Astro Server Security Toolkit** project.
Each agent is a specialized role with a defined mandate, workflow, and output format.

---

## Agent Roster

| Agent | Folder | Role |
|-------|--------|------|
| 👁️ Overseer | [`overseer/`](./overseer/AGENT.md) | Coordinates all agents, manages priorities, communicates with user |
| 🐚 Bash Reviewer | [`bash-code-reviewer/`](./bash-code-reviewer/AGENT.md) | Shell/Bash code quality, ShellCheck, input validation, style |
| 🔒 Security Reviewer | [`security-reviewer/`](./security-reviewer/AGENT.md) | Security audits, SSH/Fail2Ban/sysctl best practices, compliance |
| 🐧 Linux Reviewer | [`linux-code-reviewer/`](./linux-code-reviewer/AGENT.md) | Distro compatibility, kernel interfaces, FHS paths, systemd |
| 📈 Improvement Planner | [`improvement-planner/`](./improvement-planner/AGENT.md) | Analysis, roadmap planning, feature design, metrics |
| 🧪 QA Engineer | [`qa-engineer/`](./qa-engineer/AGENT.md) | Bats-core test automation, multi-distro container matrix, regression checks |

---

## How to Use These Agents

### Starting a Session
Always begin by activating the **Overseer** agent. It will:
1. Survey the current project state
2. Identify the right specialist agents for your task
3. Coordinate their work
4. Report back with consolidated findings

### Direct Agent Activation
You can also activate a specific specialist directly:

```
Activate the Bash Reviewer agent and review scripts/Astro-server.sh
```

```
Activate the Security Reviewer agent and audit the SSH sshd_config templates
```

```
Activate the Improvement Planner and create a plan for modularizing the main script
```

### Common Workflows

#### Full Project Audit
```
Activate the Overseer and run a full project audit across all agents.
```

#### Security Review Only
```
Activate the Security Reviewer and perform a comprehensive security audit
of all SSH templates, sysctl parameters, and Fail2Ban configurations.
```

#### Pre-Release Check
```
Activate the Overseer and run the quality gate checklist before the v1.1.0 release.
```

#### Feature Planning
```
Activate the Improvement Planner and create an implementation plan for
adding CIS Benchmark compliance checking to Astro Server.
```

---

## Agent Interaction Model

```
User Request
     │
     ▼
┌──────────┐
│ Overseer │ ◄─── Receives all reports, makes final decisions
└────┬─────┘
     │  Delegates
     ├─────────────────────────────────────────────┐
     │                     │                       │
     ▼                     ▼                       ▼
┌───────────┐    ┌──────────────────┐    ┌──────────────────┐
│   Bash    │    │   Security       │    │    Linux         │
│ Reviewer  │    │   Reviewer       │    │   Reviewer       │
└─────┬─────┘    └────────┬─────────┘    └────────┬─────────┘
      │                   │                        │
      └───────────────────┼────────────────────────┘
                          │
                          ▼
                ┌──────────────────┐
                │  Improvement     │
                │  Planner         │
                └──────────────────┘
```

---

## Escalation Protocol

| Severity | Who Acts | Timeframe |
|----------|----------|-----------|
| 🔴 Critical (security vuln, script breakage) | Overseer → User immediately | Now |
| 🟠 High (major bug, compliance gap) | Overseer consolidates → User | Same session |
| 🟡 Normal (improvement, refactor) | Relevant agent → Overseer → User | Next report |
| 🟢 Low (style, docs) | Relevant agent logs it | Weekly report |

---

## File Structure

```
.agents/
├── README.md                        ← This file
├── overseer/
│   └── AGENT.md                     ← Overseer instructions
├── bash-code-reviewer/
│   └── AGENT.md                     ← Bash reviewer instructions
├── security-reviewer/
│   └── AGENT.md                     ← Security reviewer instructions
├── linux-code-reviewer/
│   └── AGENT.md                     ← Linux reviewer instructions
└── improvement-planner/
    └── AGENT.md                     ← Improvement planner instructions
```
