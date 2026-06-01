# VM-specific tuning for the `Vm` host (Hyprland). Built via `system.build.vm`
# (see ./vm.sh), so virtualisation.* lives under `virtualisation.vmVariant`.
{ lib, pkgs, ... }:
{
  # --- Kernel / console -----------------------------------------------------
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages; # cached LTS kernel
  boot.kernelParams = [
    "console=ttyS0"
    "console=tty0"
  ];

  # Bootloader so the base config's `system.build.toplevel` is valid (needed by
  # `nixos-rebuild`/`vm-rebuild` inside the VM). build-vm direct-boots and
  # ignores this; the VM's virtio root disk is /dev/vda.
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  # --- Graphics: Hyprland under QEMU ---------------------------------------
  # QEMU's virtio-gpu has no hardware GL, so force Mesa software rendering and
  # let wlroots/Hyprland accept it. Slower than bare metal, but it renders.
  hardware.graphics.enable = true;
  environment.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBGL_ALWAYS_SOFTWARE = "1";
    WLR_RENDERER = "gles2";
  };

  # Auto-login straight into the Hyprland session, so a flaky greeter can't
  # block you from seeing the desktop. (defaultSession = "hyprland" is set by
  # the hyprland module.)
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # zsh is the login shell (modules/core/users.nix) — enable it system-wide too.
  programs.zsh.enable = true;

  # `vm-rebuild` — the in-VM rebuild loop. Builds and activates the *VM-variant*
  # toplevel (NOT the base config) so the qemu 9p store/share mounts the running
  # system depends on are preserved instead of torn down. Edit a .nix, then run
  # `vm-rebuild` inside the VM.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vm-rebuild" ''
      set -euo pipefail
      flake="''${1:-/mnt/nixos-config}"
      echo ">> building $flake#Vm (vm variant) ..."
      sys=$(${pkgs.nix}/bin/nix build --no-link --print-out-paths \
        "$flake#nixosConfigurations.Vm.config.virtualisation.vmVariant.system.build.toplevel")
      echo ">> activating $sys"
      sudo "$sys/bin/switch-to-configuration" test
      echo ">> done. current system -> $(readlink -f /run/current-system)"
    '')
  ];

  # --- QEMU / build-vm ------------------------------------------------------
  virtualisation.vmVariant.virtualisation = {
    memorySize = 6144; # MiB — Hyprland + a browser want headroom
    cores = 4;
    diskSize = 24576; # MiB, sparse qcow2
    graphics = true; # open a QEMU window; pass -nographic to run headless

    qemu.options = [ "-vga virtio" ];

    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];

    sharedDirectories.nixosconfig = {
      source = "/home/crystal/Projects/NixOS-Sly-Harvey";
      target = "/mnt/nixos-config";
    };
  };
}
