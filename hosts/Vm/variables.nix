# VM host variables — mirrors the upstream Default host, with only the changes
# that are unavoidable inside a QEMU VM. THIS FILE is where you choose things:
# swap `desktop`, `bar`, `editor`, `browser`, `terminal`, `fileManager`, etc.
# to any value listed in the comments, then run `vm-rebuild` inside the VM.
{
  username = "nixos"; # login user (initialPassword = "123", from modules/core/users.nix)

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, wayle, hyprpanel, noctalia-shell, caelestia-shell
  waybarTheme = "minimal"; # stylish, minimal
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "galaxy.webp";
  hyprlockWallpaper = "galaxy.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty, wezterm
  editor = "nixvim"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "zen-beta"; # zen-beta, firefox, floorp
  fileManager = "yazi"; # yazi, lf, thunar
  shell = "zsh"; # zsh, bash
  games = false; # emulators/Godot/etc. — left off in the VM (huge, non-visual)

  # External storage convention (see Default/variables.nix). VM imports the
  # drives module too; the upstream paths stay so the work/games mountpoints
  # don't collide (they remain unmounted under `nofail`).
  workDir = "/mnt/work";
  gamesDir = "/mnt/games";

  # Hardware
  hostname = "nixos-vm";
  videoDriver = "intel"; # VM-friendly (modesetting). nvidia is useless in QEMU.
  hidpi = false; # QEMU defaults to a low-DPI virtual screen.
  nvidiaChannel = "legacy_580"; # stable, latest, beta, legacy_xxx
  bluetoothSupport = false;
  batterySupport = false;

  # Localization
  timezone = "America/Santiago";
  locale = "en_US.UTF-8";
  clock24h = true;
  kbdLayout = "us";
  kbdVariant = "";
  consoleKeymap = "us";
  capslockAsESC = false;
}
