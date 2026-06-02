{ host, pkgs, ... }:
pkgs.writeShellScriptBin "rebuild" ''
  # Colors for output
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting..."
    exit 1
  fi

  if [ -f "$HOME/NixOS/flake.nix" ]; then
    flake=$HOME/NixOS
  elif [ -f "/etc/nixos/flake.nix" ]; then
    flake=/etc/nixos
  else
    echo "Error: flake not found. ensure flake.nix exists in either $HOME/NixOS or /etc/nixos"
    exit 1
  fi
  echo -e "''${GREEN}Flake: $flake''${NC}"
  echo -e "''${GREEN}Host: ${host}''${NC}"
  currentUser=$(logname)

  # replace username variable in variables.nix with $USER
  sudo sed -i -e "s/username = \".*\"/username = \"$currentUser\"/" "$flake/hosts/${host}/variables.nix"

  if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    cat "/etc/nixos/hardware-configuration.nix" | sudo tee "$flake/hosts/${host}/hardware-configuration.nix" >/dev/null
  else
    sudo nixos-generate-config --show-hardware-config >"$flake/hosts/${host}/hardware-configuration.nix"
  fi

  sudo git -C "$flake" add hosts/${host}/hardware-configuration.nix

  # nh os switch --hostname "${host}"
  sudo nixos-rebuild switch --flake "$flake#${host}"

  # Post-switch: refresh live Hyprland session so config changes apply without relogin.
  if command -v hyprctl >/dev/null && [ -n "$(ls /run/user/$(id -u)/hypr/ 2>/dev/null)" ]; then
    echo -e "''${GREEN}Reloading Hyprland session...''${NC}"
    hyprctl reload >/dev/null 2>&1 || true

    # Apply cursor size from home-manager's GTK settings (single source of truth).
    cursorTheme=$(awk -F'=' '/gtk-cursor-theme-name/{print $2}' "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null | tr -d '[:space:]')
    cursorSize=$(awk -F'=' '/gtk-cursor-theme-size/{print $2}' "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$cursorTheme" ] && [ -n "$cursorSize" ]; then
      hyprctl setcursor "$cursorTheme" "$cursorSize" >/dev/null 2>&1 || true
    fi

    # Waybar: home-manager restarts the systemd unit on config change, but a
    # legacy waybar exec'd by Hyprland at session start would still own the
    # socket. Kill strays, then ensure the systemd unit is running.
    pkill -u "$currentUser" -x waybar 2>/dev/null || true
    systemctl --user restart waybar.service 2>/dev/null || systemctl --user start waybar.service 2>/dev/null || true
  fi

  echo
  read -rsn1 -p"$(echo -e "''${GREEN}Press any key to continue''${NC}")"
''
