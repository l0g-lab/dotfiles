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
