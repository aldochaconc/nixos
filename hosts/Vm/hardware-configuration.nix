# Minimal, VM-friendly hardware profile.
#
# `nixos-rebuild build-vm` / `system.build.vm` provides the virtual root disk
# itself (it overrides fileSystems."/" with mkVMOverride and shares the host
# /nix/store over 9p), so here we only declare the qemu-guest profile, virtio
# kernel modules and a placeholder root so the config also evaluates as a
# normal NixOS system.
#
# This intentionally replaces the upstream Default host's hardware config, which
# is wired to the author's real machine (LUKS-encrypted root/home + fixed disk
# UUIDs) and therefore cannot boot inside a VM.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
