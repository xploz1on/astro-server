#!/usr/bin/env bash
# lib/ui.sh — Progress bars, spinners, security scorecard, and profile defaults
# Sourced by the main orchestrator; do NOT execute directly.
# Requires: lib/colors.sh sourced first.

# ── Braille spinner ──────────────────────────────────────────────────────────
spinner() {
    local pid="$1"
    local delay=0.08
    local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local -a colors=("$CYAN" "$BLUE" "$PURPLE" "$CYAN")
    local frame_count=${#frames[@]}
    local color_count=${#colors[@]}
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "  %b%s%b " "${colors[i % color_count]}" "${frames[i % frame_count]}" "$NC"
        sleep "$delay"
        printf "\r"
        i=$((i + 1))
    done
    printf "     \r"
}

# ── Animated progress bar ────────────────────────────────────────────────────
render_progress_bar() {
    local current="$1"
    local total="${2:-10}"
    local title="$3"
    local width=22
    local percent=$(( (current * 100) / total ))
    local filled=$(( (current * width) / total ))
    local empty=$(( width - filled ))

    local bar=""
    for ((b=0; b<filled; b++)); do bar+="█"; done
    for ((b=0; b<empty; b++)); do bar+="░"; done

    echo
    echo -e "${PURPLE}[${bar}] ${CYAN}${BOLD}${percent}%${NC} — ${WHITE}${BOLD}[STEP $current/$total] $title${NC}"
    echo
}

print_step() { render_progress_bar "$1" "10" "$2"; }

# ── Nerd quips shown during long operations ──────────────────────────────────
with_quips() {
    [ -n "${ASTRO_NO_JOKES:-}" ] && return 0
    local pid="$1"
    local i=0
    local -a nerd_quips=(
        "Compiling security. Please stand by while entropy accumulates..."
        "Brute-forcers hate this one weird trick."
        "Deploying phasers to stun. Shields at 100%."
        "Upgrading packages: because unpatched is just another word for adventure."
        "Beep boop: applying best practices so you don't have to."
    )
    while kill -0 "$pid" 2>/dev/null; do
        sleep 12
        echo -e "${YELLOW}${nerd_quips[i % ${#nerd_quips[@]}]}${NC}"
        i=$((i + 1))
    done
}

# ── Security scorecard ───────────────────────────────────────────────────────
render_security_scorecard() {
    local score="$1"
    local title="${2:-CURRENT SECURITY RATING}"
    local width=28
    local filled=$(( (score * width) / 100 ))
    local empty=$(( width - filled ))

    local bar="" color="$GREEN" grade="FORTIFIED"
    for ((b=0; b<filled; b++)); do bar+="█"; done
    for ((b=0; b<empty; b++)); do bar+="░"; done

    if   [ "$score" -lt 40 ]; then color="$RED";    grade="VULNERABLE (Action Required)"
    elif [ "$score" -lt 70 ]; then color="$YELLOW"; grade="MODERATE (Basic Protection)"
    elif [ "$score" -lt 90 ]; then color="$CYAN";   grade="STRONG (Hardened)"
    else                            color="$GREEN";  grade="ENTERPRISE FORTIFIED"
    fi

    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 🛡️  ASTRO SECURITY GAUGE                      ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC}  %-20s ${color}[%s] %3d/100${NC}   ${CYAN}║${NC}\n" "$title:" "$bar" "$score"
    printf "${CYAN}║${NC}  Status: %-52s ${CYAN}║${NC}\n" "$grade"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

# ── Hardening profiles ───────────────────────────────────────────────────────
DEFAULT_UPDATE_SYSTEM='y'
DEFAULT_ENABLE_UNATTENDED='y'
DEFAULT_HARDEN_SSH='y'
DEFAULT_INSTALL_FAIL2BAN='y'
DEFAULT_CONFIGURE_FIREWALL='n'
DEFAULT_KERNEL_HARDEN='y'
DEFAULT_CREATE_MONITORING='y'

PROFILE=""

apply_profile_defaults() {
    case "$PROFILE" in
        web|web-server|aggressive)
            DEFAULT_CONFIGURE_FIREWALL='y'
            ;;
        minimal)
            DEFAULT_ENABLE_UNATTENDED='n'
            DEFAULT_INSTALL_FAIL2BAN='n'
            DEFAULT_CONFIGURE_FIREWALL='n'
            ;;
        balanced|"") : ;;
        *)           : ;;
    esac
}
