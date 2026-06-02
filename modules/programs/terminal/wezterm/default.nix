{ pkgs, host, ... }:
let
  vars = import ../../../../hosts/${host}/variables.nix;
  inherit (vars) workDir;
  hidpi = vars.hidpi or true;
  fontSize = if hidpi then "12.0" else "10.0";
  wezConfig = builtins.replaceStrings
    [ "@workDir@" "@fontSize@" ]
    [ workDir fontSize ]
    (builtins.readFile ./wezterm.lua);
in
{
  home-manager.sharedModules = [
    (_: {
      home.packages = [ pkgs.wezterm ];
      xdg.configFile."wezterm/wezterm.lua".text = wezConfig;
    })
  ];
}
