let
  username = "awcc"; # auto-set with install.sh, live-install.sh, and rebuild scripts.
  homeDir = "/home/${username}";
in
{
  inherit username;

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, wayle, hyprpanel, noctalia-shell, caelestia-shell
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "galaxy.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "galaxy.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "nixvim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "zen-beta"; # zen-beta, firefox, floorp
  fileManager = "yazi"; # yazi, lf, thunar
  shell = "zsh"; # zsh, bash
  games = false; # Enable/Disable gaming module

  # External storage convention used by shell aliases, file-manager bookmarks,
  # tmux-sessionizer, dlna, etc. A fresh machine has no /mnt/{work,games}, so
  # fall back to $HOME — aliases like `work`/`games`/`projects` resolve to ~
  # instead of pointing at unmounted paths. Override per host if you actually
  # mount external drives (and re-enable modules/hardware/drives).
  workDir = homeDir;
  gamesDir = homeDir;

  # Hardware
  hostname = "nix";
  videoDriver = "intel"; # nvidia, amdgpu, intel — intel is the safest fallback (iGPU/VM-friendly)
  hidpi = false; # Set true on >=1440p panels to scale fonts/cursors up.
  nvidiaChannel = "legacy_580"; # stable, latest, beta, legacy_xxx (unused when videoDriver != nvidia)
  bluetoothSupport = false; # Whether your motherboard supports bluetooth
  batterySupport = false; # Whether device has a battery (laptop)

  # Localization
  timezone = "America/Santiago";
  locale = "en_US.UTF-8";
  clock24h = true;
  kbdLayout = "us,latam"; # US primary, Latin-American secondary; toggle via SUPER xkb switch
  kbdVariant = "";
  consoleKeymap = "us";
  capslockAsESC = false;
}
