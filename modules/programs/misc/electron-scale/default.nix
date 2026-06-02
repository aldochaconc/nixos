{
  host,
  lib,
  pkgs,
  ...
}:
let
  vars = import ../../../../hosts/${host}/variables.nix;
  hidpi = vars.hidpi or true;

  # Chromium/Electron's UI scale knob. 1.0 = 100%; 0.85 ≈ 85%.
  # Why a variable: 1366x768 panels (T430) want ~0.85; a 1080p that still
  # feels too big can drop to 0.8. Override per host with `electronScale`.
  scaleFactor = vars.electronScale or "0.85";

  # name = basename of the upstream .desktop (without .desktop)
  # pkg  = derivation that ships that file under share/applications/
  apps = [
    { name = "code";             pkg = pkgs.vscode; }
    { name = "code-url-handler"; pkg = pkgs.vscode; }
    { name = "slack";            pkg = pkgs.slack; }
    { name = "github-desktop";   pkg = pkgs.github-desktop; }
    { name = "obsidian";         pkg = pkgs.obsidian; }
    { name = "discord";          pkg = pkgs.discord; }
  ];

  # Copy the upstream .desktop and append --force-device-scale-factor right
  # after the binary in every Exec= line — catches both top-level launches
  # and [Desktop Action *] sub-entries (e.g. code's "new-empty-window").
  patch = { name, pkg }:
    pkgs.runCommand "${name}-scaled.desktop" { } ''
      install -Dm644 ${pkg}/share/applications/${name}.desktop $out
      sed -i -E 's|^(Exec=[^[:space:]]+)|\1 --force-device-scale-factor=${scaleFactor}|' $out
    '';

  entries = lib.listToAttrs (map (app: {
    name = "applications/${app.name}.desktop";
    value = { source = patch app; };
  }) apps);
in
{
  # ~/.local/share/applications/ (XDG_DATA_HOME) wins over the system path,
  # so these overrides shadow the upstream entries for every launcher that
  # respects the XDG spec (fuzzel, rofi, wofi, gnome, plasma, etc.).
  home-manager.sharedModules = lib.optional (!hidpi) (_: {
    xdg.dataFile = entries;
  });
}
