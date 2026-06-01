# VM host — a faithful mirror of the upstream Default host (Hyprland + the real
# apps and theming), with ONLY the changes required to run inside a QEMU VM:
#   * ./hardware-configuration.nix  -> virtio disk, no LUKS (Default's is wired
#       to the author's encrypted physical machine and can't boot in a VM).
#   * ./vm.nix                      -> QEMU/build-vm tuning + bootloader + the
#       software-GL env Hyprland needs under QEMU.
#   * modules/core/boot.nix is NOT imported — it configures real-hardware
#       GRUB/EFI that conflicts with build-vm; vm.nix supplies a VM bootloader.
#   * host-packages.nix is NOT imported — RetroArch + 14 emulator cores + Godot
#       etc. are a huge, non-visual build (your choice: desktop-only).
{ lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./vm.nix

    ../../modules/scripts

    # Core Modules (same set as Default, minus boot.nix — see header)
    ../../modules/core/bash.nix
    ../../modules/core/zsh.nix
    ../../modules/core/starship.nix
    ../../modules/core/fonts.nix
    ../../modules/core/hardware.nix
    ../../modules/core/network.nix
    ../../modules/core/dns.nix
    ../../modules/core/nh.nix
    ../../modules/core/packages.nix
    ../../modules/core/printing.nix
    ../../modules/core/sddm.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/syncthing.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix

    # Optional / hardware / desktop / programs (driven by variables.nix)
    ../../modules/hardware/drives # all mounts use nofail -> harmless in a VM
    ../../modules/hardware/video/${vars.videoDriver}.nix
    ../../modules/desktop/${vars.desktop}
    ../../modules/programs/browser/${vars.browser}
    ../../modules/programs/terminal/${vars.terminal}
    ../../modules/programs/editor/${vars.editor}
    ../../modules/programs/file-manager/${vars.fileManager}
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/media/discord
    ../../modules/programs/media/spicetify
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    ../../modules/programs/misc/lact
  ]
  ++ lib.optional (vars.games == true) ../../modules/core/games.nix;
}
