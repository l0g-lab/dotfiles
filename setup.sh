#!/bin/bash
set -euo pipefail # no command output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN_SRC="$SCRIPT_DIR/local/bin"
LOCAL_BIN_DEST="$HOME/.local/bin"

echo -e "Dotfile directory: \e[35m$SCRIPT_DIR\e[0m"

#########################################
# Helper functions
#########################################

confirm() {
    local prompt="$1"
    read -rp "$prompt (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

symlink() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        echo -e "\e[36m✔\e[0m Already linked: $dest"
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        if ! confirm "Overwrite $dest?"; then
            echo -e "\e[31m✖\e[0m Skipping $dest"
            return
        fi
        rm -rf "$dest"
    fi

    ln -s "$src" "$dest"
    echo -e "\e[32m→\e[0m Linked $dest"
}

xfapply() {
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


#########################################
# Dotfile Symlinks
#########################################

configs=(
    "bashrc:$HOME/.bashrc"
    "Xdefaults:$HOME/.Xdefaults"
    "tmux.conf:$HOME/.tmux.conf"
    "i3:$HOME/.config/i3"
    "fluxbox:$HOME/.config/fluxbox"
    "spectrwm.conf:$HOME/.spectrwm.conf"
    "gitconfig:$HOME/.gitconfig"
    "nvim:$HOME/.config/nvim"
    "vimrc:$HOME/.vimrc"
    "local/bin:$HOME/.local/bin"
)

echo
for config in "${configs[@]}"; do
  IFS=':' read -r src_file dest_path <<< "$config"
  src_path="$SCRIPT_DIR/$src_file"

  if [[ ! -e "$src_path" ]]; then
      echo -e "\e[31m✖\e[0m Source not found, skipping $src_path"
      continue
  fi

  if confirm "Install $src_file"?; then
      symlink "$src_path" "$dest_path"
  else
      echo -e "\e[31m✖\e[0m Skipping $src_file"
  fi
done

#########################################
# XFCE Configuration
#########################################

if confirm "Configure XFCE4 settings?"; then
    
    echo "🔧 Applying complete XFCE configuration..."

    command -v xfconf-query >/dev/null || {
        echo -e "\e[31m✖\e[0mxfconf-query not found. Install XFCE first."
        exit 1
    }
    
    ############################################################
    # PANEL SYMLINK
    ############################################################
    PANEL_SRC="xfce4/panel"
    PANEL_DEST="$HOME/.config/xfce4/panel"
    PANEL_CONFIG_SRC="xfce4/xfconf/xfce4-panel.xml"
    PANEL_CONFIG_DEST="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"

    if [[ -d "$PANEL_SRC" ]]; then
        if [[ -L "$PANEL_DEST" ]] || [[ -d "$PANEL_DEST" ]]; then
            echo -e "\e[32m✔\e[0m Removing old panel config: $PANEL_DEST"
            rm -rf "$PANEL_DEST"
        fi
        mkdir -p "$(dirname "$PANEL_DEST")"
        symlink "$PANEL_SRC" "$PANEL_DEST"
        symlink "$PANEL_CONFIG_SRC" "$PANEL_CONFIG_DEST"
        # echo "✔ Symlinked XFCE4 panel config: $PANEL_DEST -> $PANEL_SRC"
    else
        echo -e "\e[31m✖\e[0m Panel source not found: $PANEL_SRC"
    fi

    ############################################################
    # KEYBOARD SHORTCUTS
    ############################################################
    K="xfce4-keyboard-shortcuts"
    
    xfapply "$K" "/commands/custom/override" bool true
    xfapply "$K" "/xfwm4/custom/override" bool true
    
    # Commands
    xfapply "$K" "/commands/custom/<Alt>F2" string "xfce4-appfinder"
    xfapply "$K" "/commands/custom/<Alt>F2/startup-notify" bool true
    xfapply "$K" "/commands/custom/Print" string "flameshot gui"
    xfapply "$K" "/commands/custom/<Primary>Escape" string "xfdesktop --menu"
    xfapply "$K" "/commands/custom/<Primary><Alt>Delete" string "xfce4-session-logout"
    xfapply "$K" "/commands/custom/<Primary><Alt>t" string "exo-open --launch TerminalEmulator"
    xfapply "$K" "/commands/custom/<Primary><Alt>f" string "thunar"
    xfapply "$K" "/commands/custom/<Primary><Alt>l" string "xflock4"
    xfapply "$K" "/commands/custom/<Alt>F1" string "xfce4-popup-applicationsmenu"
    xfapply "$K" "/commands/custom/<Primary><Shift>Escape" string "xfce4-taskmanager"
    xfapply "$K" "/commands/custom/<Primary><Alt>Escape" string "xkill"
    xfapply "$K" "/commands/custom/HomePage" string "exo-open --launch WebBrowser"
    xfapply "$K" "/commands/custom/XF86Display" string "xfce4-display-settings --minimal"
    xfapply "$K" "/commands/custom/<Super>p" string "$HOME/.local/bin/xfce-dmenu-desktop"
    xfapply "$K" "/commands/custom/<Super>Enter" string "exo-open --launch TerminalEmulator"
    
    # Workspace switching
    for i in {1..10}; do
      xfapply "$K" "/xfwm4/custom/<Super>$i" string "workspace_${i}_key"
    done
    
    xfapply "$K" "/xfwm4/custom/<Super>Tab" string "switch_window_key"
    xfapply "$K" "/xfwm4/custom/<Alt>Tab" string "cycle_windows_key"
    xfapply "$K" "/xfwm4/custom/<Alt><Shift>Tab" string "cycle_reverse_windows_key"
    
    ############################################################
    # TERMINAL
    ############################################################
    
    T="xfce4-terminal"
    
    xfapply "$T" "/title-mode" string "TERMINAL_TITLE_REPLACE"
    xfapply "$T" "/misc-menubar-default" bool false
    xfapply "$T" "/shortcuts-no-menukey" bool true
    xfapply "$T" "/scrolling-unlimited" bool true
    xfapply "$T" "/scrolling-bar" string "TERMINAL_SCROLLBAR_NONE"
    xfapply "$T" "/misc-cursor-blinks" bool true
    xfapply "$T" "/font-name" string "JetBrainsMonoNL Nerd Font Mono 12"
    xfapply "$T" "/font-use-system" bool false
    xfapply "$T" "/misc-tab-close-middle-click" bool false
    xfapply "$T" "/misc-middle-click-opens-uri" bool true
    xfapply "$T" "/background-mode" string "TERMINAL_BACKGROUND_TRANSPARENT"
    xfapply "$T" "/background-darkness" double 0.85
    
    ############################################################
    # XFWM4
    ############################################################
    
    W="xfwm4"
    BASE="/general"
    
    xfapply "$W" "$BASE/activate_action" string bring
    xfapply "$W" "$BASE/borderless_maximize" bool true
    xfapply "$W" "$BASE/click_to_focus" bool false
    xfapply "$W" "$BASE/easy_click" string Alt
    xfapply "$W" "$BASE/focus_delay" int 5
    xfapply "$W" "$BASE/focus_hint" bool true
    xfapply "$W" "$BASE/focus_new" bool true
    xfapply "$W" "$BASE/raise_on_click" bool true
    xfapply "$W" "$BASE/raise_on_focus" bool false
    xfapply "$W" "$BASE/prevent_focus_stealing" bool false
    
    xfapply "$W" "$BASE/theme" string Blackwall
    xfapply "$W" "$BASE/title_alignment" string center
    xfapply "$W" "$BASE/title_font" string "JetBrainsMonoNL Nerd Font Propo 9"
    
    xfapply "$W" "$BASE/use_compositing" bool true
    xfapply "$W" "$BASE/unredirect_overlays" bool true
    xfapply "$W" "$BASE/vblank_mode" string auto
    xfapply "$W" "$BASE/shadow_opacity" int 50
    xfapply "$W" "$BASE/shadow_delta_y" int -3
    
    xfapply "$W" "$BASE/workspace_count" int 10
    xfapply "$W" "$BASE/wrap_cycle" bool true
    xfapply "$W" "$BASE/wrap_layout" bool true
    xfapply "$W" "$BASE/wrap_resistance" int 10
    xfapply "$W" "$BASE/scroll_workspaces" bool true
    
    xfapply "$W" "$BASE/workspace_names" array \
      "1:net" "2:term" "3:file" "4:[4]" "5:com" \
      "6:vpn" "7:misc" "8:mult" "9:mail" "0:sys"

    echo -e "\e[32m✔\e[0m XFCE configuration applied"

else
    echo -e "\e[31m✖\e[0m Skipping XFCE configuration"
fi

echo -e "\e[32m✔\e[0m All requested configs applied"
