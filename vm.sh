#!/usr/bin/env bash
# Build and launch the lightweight test VM (nixosConfigurations.Vm).
#
# Usage:
#   ./vm.sh            # build + launch the graphical VM
#   ./vm.sh build      # only build the VM image
#   ./vm.sh headless   # build + launch with serial console, no window
#   ./vm.sh ssh        # ssh into a running VM (user: nixos, pass: 123)
#
# Works on a non-NixOS host (e.g. Arch) with the Nix package manager + KVM.
set -euo pipefail

HOST="Vm"
FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")
ATTR="${FLAKE_DIR}#nixosConfigurations.${HOST}.config.system.build.vm"

build() {
  echo ">> Building VM for host '${HOST}' ..."
  nix "${NIX_FLAGS[@]}" build "${ATTR}" --print-build-logs --out-link "${FLAKE_DIR}/result"
}

run_script() {
  # The generated launcher is named after the VM hostname (run-nixos-vm-vm).
  local s
  s="$(echo "${FLAKE_DIR}"/result/bin/run-*-vm)"
  [ -x "${s}" ] || { echo "VM launcher not found; build first." >&2; exit 1; }
  echo "${s}"
}

case "${1:-launch}" in
  build)
    build
    ;;
  headless)
    build
    echo ">> Launching headless (serial console). Ctrl-A X to quit QEMU."
    exec "$(run_script)" -nographic
    ;;
  ssh)
    exec ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 nixos@localhost
    ;;
  launch | "")
    build
    echo ">> Launching VM window. Login: nixos / 123 (auto-login enabled)."
    echo ">> SSH from another terminal:  ./vm.sh ssh"
    exec "$(run_script)"
    ;;
  *)
    echo "Unknown command: ${1}" >&2
    echo "Usage: ./vm.sh [build|headless|ssh|launch]" >&2
    exit 1
    ;;
esac
