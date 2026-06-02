{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obsidian
    godot # Game/2D-3D engine (development)
    proton-vpn # VPN
    github-desktop
    slack
    google-chrome
    vscode
    # pokego # Overlayed

    # Gaming stack disabled for the T430 (HD 4000): emulators like PCSX2/Dolphin
    # don't run well on Ivy Bridge integrated graphics. Re-add retroarch.withCores
    # and ludusavi here if you change your mind.
  ];
}
