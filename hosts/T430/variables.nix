{
  username = "awcc"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, wayle, hyprpanel, noctalia-shell, caelestia-shell
  waybarTheme = "stylish"; # stylish, minimal
  sddmTheme = "black_hole"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "cyberpunk.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "cyberpunk.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "neovim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "firefox"; # zen-beta, firefox, floorp
  fileManager = "yazi"; # yazi, lf, thunar
  shell = "zsh"; # zsh, bash
  games = false; # Enable/Disable gaming module

  # Hardware
  hostname = "T430";
  videoDriver = "intel"; # nvidia, amdgpu, intel
  legacyIntel = true; # Gen4–Gen7 iGPU (HD 4000/Ivy Bridge) → use i965 instead of iHD
  nvidiaChannel = "legacy_580"; # stable, latest, beta, legacy_xxx (unused when videoDriver != nvidia)
  bluetoothSupport = true; # Whether your motherboard supports bluetooth
  batterySupport = true; # Whether device has a battery (laptop)

  # Localization
  timezone = "America/Santiago";
  locale = "es_CL.UTF-8";
  clock24h = true;
  kbdLayout = "jp,us,latam"; # Japanese (JIS) primary; switch with SUPER-controlled xkb toggle
  kbdVariant = ""; # empty = default variant per layout (jp=JIS, us=QWERTY, latam=Spanish)
  consoleKeymap = "jp106";
  capslockAsESC = false;
}
