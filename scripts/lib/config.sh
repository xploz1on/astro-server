#!/usr/bin/env bash
# lib/config.sh — YAML Configuration Parser & Loader
# Provides: load_config(), parse_yaml()
# Exports all values from config/astro.yml as CONF_ prefix variables

# POSIX-compliant YAML parser for bash (no dependencies)
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

load_config() {
    local config_file
    # Allow tests to override the root directory
    local root_dir="${ASTRO_ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    config_file="$root_dir/config/astro.yml"

    if [ ! -f "$config_file" ]; then
        echo -e "\033[0;31m[ERROR] Configuration file not found: $config_file\033[0m" >&2
        return 1
    fi

    # Parse the YAML file and export all variables into the current shell
    eval "$(parse_yaml "$config_file" "CONF_")"
}
