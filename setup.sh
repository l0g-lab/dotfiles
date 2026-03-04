#!/bin/bash

# Create symlinks to install dotfiles
set -e # not command output

declare -a configs=(
    "bashrc:$HOME/.bashrc"
    "Xdefaults:$HOME/.Xdefaults"
    "tmux.conf:$HOME/.tmux.conf"
    "i3:$HOME/.config/i3"
    "fluxbox:$HOME/.config/fluxbox"
    "spectrwm.conf:$HOME/.spectrwm.conf"
    "gitconfig:$HOME/.gitconfig"
    "nvim:$HOME/.config/nvim"
    "vimrc:$HOME/.vimrc"
    "xfce4/panel:$HOME/.config/xfce4/panel"
    "xfce4/xfconf/xfce4-panel.xml:$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
    # "xfce4/xfconf/xfce4-terminal.xml:$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml"
    # "xfce4/xfconf/xfce4-keyboard-shortcuts.xml:$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
    # "xfce4/xfconf/xfwm4.xml:$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
)

local_scripts_src="local/bin"
local_scripts_dest="$HOME/.local/bin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: $SCRIPT_DIR"

setup_symlink() {
    local source_file="$1"
    local dest_link="$2"

    # Check if destination already exists
    if [[ -e "$dest_link" ]] || [[ -L "$dest_link" ]]; then
        # If it's already a symlink to the correct target, do nothing
        if [[ -L "$dest_link" ]] && [[ "$(readlink -f "$dest_link")" == "$(readlink -f "$source_file")" ]]; then
            echo "Symlink already exists and points to correct target: $dest_link -> $source_file"
            return 0
        else
            echo "Warning: '$dest_link' already exists." >&2
            read -p "Overwrite? (y/N): " -n 1 -r confirm
            echo
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                echo "Operation cancelled." >&2
                return 1
            fi
            rm -rf "$dest_link"
        fi
    fi

    # Create parent directory if it doesn't exist
    local dest_dir="$(dirname "$dest_link")"
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
    fi

    # Create the symbolic link
    if ln -s "$source_file" "$dest_link"; then
        echo "Symbolic link created: $dest_link -> $source_file"
        return 0
    else
        echo "Error: Failed to create symbolic link." >&2
        return 1
    fi
}

# Helper function to apply xfce4 settings via xfquery
xfquery-apply() {
  local channel="$1"
  local path="$2"
  local type="$3"
  shift 3

  # Remove existing value (keeps idempotency clean)
  xfconf-query -c "$channel" -p "$path" -r 2>/dev/null || true

  if [ "$type" = "array" ]; then
    local args=()
    for val in "$@"; do
      args+=(-t string -s "$val")
    done
    xfconf-query -c "$channel" -p "$path" -n --force-array "${args[@]}"
  else
    xfconf-query -c "$channel" -p "$path" -n -t "$type" -s "$1"
  fi
}

for config in "${configs[@]}"; do
  IFS=':' read -r src_file dest_path <<< "$config"
  src_path="$SCRIPT_DIR/$src_file"

  if [[ ! -e "$src_path" ]]; then
      echo "Source not found, skipping: $src_path"
      continue
  fi

  echo
  read -p "Install $src_file? (y/n): " -n 1 -r response
  echo
  if [[ "$response" =~ ^[Yy]$ ]]; then

    if setup_symlink "$src_path" "$dest_path"; then
        echo "Setup complete: $src_file"
    else
        echo "Failed: $src_file"
    fi
  else
    echo "Skipping: $src_file"
  fi
done

# Handle local/bin scripts separately (copy multiple files)
echo
read -p "Install local scripts to ~/.local/bin/? (y/n): " -n 1 -r response
echo
if [[ "$response" =~ ^[Yy]$ ]]; then
    src_dir="$SCRIPT_DIR/$local_scripts_src"
    if [[ ! -d "$src_dir" ]]; then
        echo "Local scripts directory not found: $src_dir"
    else
        mkdir -p "$local_scripts_dest"
        cp -f "$src_dir"/* "$local_scripts_dest"/ 2>/dev/null || true
        echo "Local scripts installed to: $local_scripts_dest"
    fi
else
    echo "Skipping local scripts"
fi
echo

echo "Applying XFCE configuration..."
############################################################
# KEYBOARD SHORTCUTS
############################################################

K="xfce4-keyboard-shortcuts"

xfquery-apply "$K" "/commands/custom/override" bool true
xfquery-apply "$K" "/xfwm4/custom/override" bool true

# Commands
xfquery-apply "$K" "/commands/custom/<Alt>F2" string "xfce4-appfinder"
xfquery-apply "$K" "/commands/custom/<Alt>F2/startup-notify" bool true
xfquery-apply "$K" "/commands/custom/Print" string "flameshot gui"
xfquery-apply "$K" "/commands/custom/<Primary>Escape" string "xfdesktop --menu"
xfquery-apply "$K" "/commands/custom/<Primary><Alt>Delete" string "xfce4-session-logout"
xfquery-apply "$K" "/commands/custom/<Primary><Alt>t" string "exo-open --launch TerminalEmulator"
xfquery-apply "$K" "/commands/custom/<Primary><Alt>f" string "thunar"
xfquery-apply "$K" "/commands/custom/<Primary><Alt>l" string "xflock4"
xfquery-apply "$K" "/commands/custom/<Alt>F1" string "xfce4-popup-applicationsmenu"
xfquery-apply "$K" "/commands/custom/<Primary><Shift>Escape" string "xfce4-taskmanager"
xfquery-apply "$K" "/commands/custom/<Primary><Alt>Escape" string "xkill"
xfquery-apply "$K" "/commands/custom/HomePage" string "exo-open --launch WebBrowser"
xfquery-apply "$K" "/commands/custom/XF86Display" string "xfce4-display-settings --minimal"
xfquery-apply "$K" "/commands/custom/<Super>p" string "$HOME/.local/bin/xfce-dmenu-desktop"
xfquery-apply "$K" "/commands/custom/<Super>Enter" string "exo-open --launch TerminalEmulator"

# Workspace switching
for i in {1..10}; do
  xfquery-apply "$K" "/xfwm4/custom/<Super>$i" string "workspace_${i}_key"
done

xfquery-apply "$K" "/xfwm4/custom/<Super>Tab" string "switch_window_key"
xfquery-apply "$K" "/xfwm4/custom/<Alt>Tab" string "cycle_windows_key"
xfquery-apply "$K" "/xfwm4/custom/<Alt><Shift>Tab" string "cycle_reverse_windows_key"

############################################################
# TERMINAL
############################################################

T="xfce4-terminal"

xfquery-apply "$T" "/title-mode" string "TERMINAL_TITLE_REPLACE"
xfquery-apply "$T" "/misc-menubar-default" bool false
xfquery-apply "$T" "/shortcuts-no-menukey" bool true
xfquery-apply "$T" "/scrolling-unlimited" bool true
xfquery-apply "$T" "/scrolling-bar" string "TERMINAL_SCROLLBAR_NONE"
xfquery-apply "$T" "/misc-cursor-blinks" bool true
xfquery-apply "$T" "/font-name" string "JetBrainsMonoNL Nerd Font Mono 12"
xfquery-apply "$T" "/font-use-system" bool false
xfquery-apply "$T" "/misc-tab-close-middle-click" bool false
xfquery-apply "$T" "/misc-middle-click-opens-uri" bool true
xfquery-apply "$T" "/background-mode" string "TERMINAL_BACKGROUND_TRANSPARENT"
xfquery-apply "$T" "/background-darkness" double 0.85

############################################################
# XFWM4
############################################################

W="xfwm4"
BASE="/general"

xfquery-apply "$W" "$BASE/activate_action" string bring
xfquery-apply "$W" "$BASE/borderless_maximize" bool true
xfquery-apply "$W" "$BASE/click_to_focus" bool false
xfquery-apply "$W" "$BASE/easy_click" string Alt
xfquery-apply "$W" "$BASE/focus_delay" int 5
xfquery-apply "$W" "$BASE/focus_hint" bool true
xfquery-apply "$W" "$BASE/focus_new" bool true
xfquery-apply "$W" "$BASE/raise_on_click" bool true
xfquery-apply "$W" "$BASE/raise_on_focus" bool false
xfquery-apply "$W" "$BASE/prevent_focus_stealing" bool false

xfquery-apply "$W" "$BASE/theme" string Blackwall
xfquery-apply "$W" "$BASE/title_alignment" string center
xfquery-apply "$W" "$BASE/title_font" string "JetBrainsMonoNL Nerd Font Propo 9"

xfquery-apply "$W" "$BASE/use_compositing" bool true
xfquery-apply "$W" "$BASE/unredirect_overlays" bool true
xfquery-apply "$W" "$BASE/vblank_mode" string auto
xfquery-apply "$W" "$BASE/shadow_opacity" int 50
xfquery-apply "$W" "$BASE/shadow_delta_y" int -3

xfquery-apply "$W" "$BASE/workspace_count" int 10
xfquery-apply "$W" "$BASE/wrap_cycle" bool true
xfquery-apply "$W" "$BASE/wrap_layout" bool true
xfquery-apply "$W" "$BASE/wrap_resistance" int 10
xfquery-apply "$W" "$BASE/scroll_workspaces" bool true

xfquery-apply "$W" "$BASE/workspace_names" array \
  "1:net" \
  "2:term" \
  "3:file" \
  "4:[4]" \
  "5:com" \
  "6:vpn" \
  "7:misc" \
  "8:mult" \
  "9:mail" \
  "0:sys"

echo "Done."
