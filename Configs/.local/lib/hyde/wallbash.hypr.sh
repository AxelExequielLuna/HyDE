#!/bin/env bash

scrDir="$(dirname "$(realpath "$0")")"
export scrDir
# shellcheck disable=SC1091
source "${scrDir}/globalcontrol.sh"
confDir="${confDir:-$XDG_CONFIG_HOME}"
cacheDir="${cacheDir:-$XDG_CACHE_HOME/hyde}"
HYDE_THEME="${HYDE_THEME:-}"
HYDE_THEME_DIR="${HYDE_THEME_DIR:-$confDir/hyde/themes/$HYDE_THEME}"
enableWallDcol="${enableWallDcol:-0}"
hyprWallTheme=${cacheDir}/wallbash/hypr.theme

# sed '1d' "${HYDE_THEME_DIR}/hypr.theme" >"${confDir}/hypr/themes/theme.conf"

# Validate the theme configuration file
cat <<WALLBASH >"${confDir}/hypr/themes/wallbash.conf"
# Auto-generated by HyDE // Read-only
# // ----------------------------
# HyDE Theme: ${HYDE_THEME}
# Configuration File: "${HYDE_THEME_DIR}/hypr.theme"
# Wallbash Mode : $(sed -e 's/^0$/theme/' -e 's/^1$/auto/' -e 's/^2$/dark/' -e 's/^3$/light/' <<<"${enableWallDcol}")
# // ----------------------------

\$HYDE_THEME=${HYDE_THEME}
\$GTK_THEME=$(get_hyprConf 'GTK_THEME')
\$COLOR-SCHEME=$(get_hyprConf 'COLOR_SCHEME')
\$ICON_THEME=$(get_hyprConf 'ICON_THEME')

\$CURSOR_THEME=$(get_hyprConf 'CURSOR_THEME')
\$CURSOR_SIZE=$(get_hyprConf 'CURSOR_SIZE')

\$FONT=$(get_hyprConf 'FONT')
\$FONT_SIZE=$(get_hyprConf 'FONT_SIZE')
\$DOCUMENT_FONT=$(get_hyprConf 'DOCUMENT_FONT')
\$DOCUMENT_FONT_SIZE=$(get_hyprConf 'DOCUMENT_FONT_SIZE')
\$MONOSPACE_FONT=$(get_hyprConf 'MONOSPACE_FONT')
\$MONOSPACE_FONT_SIZE=$(get_hyprConf 'MONOSPACE_FONT_SIZE')


\$CODE_THEME=$(get_hyprConf 'CODE_THEME')
\$SDDM_THEME=$(get_hyprConf 'SDDM_THEME')

# // ----------------------------
# README:
# Values above are derived and sanitized from the theme.conf file,
# This is to ensure themes won't have any 'exec' or 'source'
# commands that could potentially harm the system
#  or undesired behavior.
#
# Dear Theme Owner:
# You can still add your own custom 'exec' or 'source' commands
#  by adding it as variable, examples (you can name the variable anything):
# Note that you should indicate it in your README.md
#
#
# -- ⌨️ theme.conf --
# \$RUN_CMD="some_command"
# \$SOURCE_FILE="/some/files"
#
#
# -- ⌨️ hyprland.conf --
# exec = \${RUN_CMD}"
# source = \${SOURCE_FILE}
# exec = Hyde code theme \$CODE_THEME # Setting the code theme

# // ----------------------------
WALLBASH

if grep -q "#//---Wallbash mode enabled---" "${confDir}/hypr/themes/wallbash.conf"; then
    # Remove lines below the detected line
    sed -i '/#\/\/---Wallbash mode enabled---/,$d' "${confDir}/hypr/themes/wallbash.conf"
fi
if [[ "${enableWallDcol}" -gt 0 ]]; then
    cat "${hyprWallTheme}" >>"${confDir}/hypr/themes/wallbash.conf"
fi

#? Post deployment

#// cleanup
# Define an array of patterns to remove
# Supports regex patterns
deleteRegex=(
    "^ *exec"
    "^ *decoration[^:]*: *drop_shadow"
    "^ *drop_shadow"
    "^ *decoration[^:]*: *shadow *="
    "^ *decoration[^:]*: *col.shadow* *="
    "^ *shadow_"
    "^ *col.shadow*"
)

deleteRegex+=("${hypr_sanitize[@]}")

# Loop through each pattern and remove matching lines
for pattern in "${deleteRegex[@]}"; do
    grep -E "${pattern}" "${confDir}/hypr/themes/theme.conf" | while read -r line; do
        sed -i "\|${line}|d" "${confDir}/hypr/themes/theme.conf"
        print_log -sec "theme" -warn "sanitize" "${line}"
    done
done
