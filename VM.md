# Testing this config in a VM

This repo ships a lightweight, VM-friendly NixOS host (`Vm`) so you can boot the
config in QEMU and iterate on it **without** touching your real machine. It runs
fine on a non-NixOS host (e.g. Arch) that only has the Nix package manager + KVM.

## Why a separate `Vm` host?

The upstream `Default` host is wired to the author's physical machine and cannot
boot in a VM as-is:

- `hardware-configuration.nix` mounts **LUKS-encrypted** root/home with fixed
  disk UUIDs that don't exist in a VM.
- `videoDriver = "nvidia"` — useless in QEMU (no NVIDIA passthrough here).
- `games = true` + RetroArch/emulators/Godot/etc. — a huge, slow build.

`hosts/Vm/` is a slim derivative:

- No LUKS; `build-vm` supplies the virtual disk and shares the host store.
- Graphics: plain `modesetting` on QEMU's virtio-gpu.
- Desktop: **i3 (X11)** — renders reliably under QEMU. No games.
- Only modules covered by `cache.nixos.org`, so it builds even though your user
  is not a Nix `trusted-user`.

## Quick start

```sh
./vm.sh            # build + launch the graphical VM (login: nixos / 123)
./vm.sh build      # build the VM image only
./vm.sh headless   # boot with a serial console, no window
./vm.sh ssh        # ssh -p 2222 nixos@localhost  (from another terminal)
```

The VM gets 4 GiB RAM, 4 cores and a 16 GiB sparse disk (see `hosts/Vm/vm.nix`).

## The edit → rebuild loop ("pull a package, rebuild")

The host repo is shared into the VM at **`/mnt/nixos-config`** (9p), and the
VM reuses the host `/nix/store`, so rebuilds are fast.

1. Launch the VM: `./vm.sh` (or `./vm.sh headless`).
2. From another terminal, get a shell in the VM: `./vm.sh ssh`.
3. Edit a config file — e.g. remove a package. `htop` is a good test target;
   it's declared in `hosts/Vm/vm.nix` under `environment.systemPackages`.
   Edit it on the **host** (the change is visible at `/mnt/nixos-config`), or
   directly inside the VM.
4. Rebuild inside the VM:

   ```sh
   sudo nixos-rebuild switch --flake /mnt/nixos-config#Vm
   ```

   Then verify: `command -v htop` should now fail.

> Note on flakes + git: Nix flakes only see files **tracked by git**. New files
> must be `git add`-ed (staging is enough, no commit needed) before the flake
> can see them. Editing an already-tracked file works without staging.

## Important: your host is not NixOS

On an Arch host you cannot `nixos-rebuild switch` the machine itself — there is
no NixOS system to switch. All rebuilds happen **inside the VM** (above), or by
rebuilding the VM image on the host (`./vm.sh build`) and relaunching.
