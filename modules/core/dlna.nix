{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) hostname workDir;
in
{

  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = "${hostname}";
      media_dir = [
        # A = Audio, P = Pictures, V, = Videos, PV = Pictures and Videos.
        # "A,${workDir}/Pimsleur/Russian"
        "${workDir}/Pimsleur"
        "${workDir}/Media/Films"
        "${workDir}/Media/Series"
        "${workDir}/Media/Videos"
        "${workDir}/Media/Music"
      ];
      inotify = "yes";
      log_level = "warn";
    };
  };
  users.users.minidlna = {
    extraGroups = [ "users" ]; # so minidlna can access the files.
  };
}
