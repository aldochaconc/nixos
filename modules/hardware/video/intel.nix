{ pkgs, lib, config, host, ... }:
let
  # Older Intel iGPUs (Gen4–Gen7, e.g. HD 4000 / Ivy Bridge) are NOT supported by
  # intel-media-driver (iHD), which only covers Gen8+ (Broadwell and newer). Those
  # chips must use the legacy intel-vaapi-driver (i965). Opt in per-host via
  # `legacyIntel = true;` in the host variables.nix (defaults to false = modern iHD).
  legacyIntel = (import ../../../hosts/${host}/variables.nix).legacyIntel or false;
  vaapiDriver = if legacyIntel then "i965" else "iHD";
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    LIBVA_DRIVER_NAME = vaapiDriver;
  };

  boot.kernelParams = [
    "intel_pstate=active"
    "mem_sleep_default=deep" # Allow deepest sleep states
  ]
  # Gen8+ machines are typically paired with NVMe storage. Older Ivy Bridge era
  # laptops (T430 etc.) ship with SATA SSDs where this parameter is a no-op.
  # i915 features are Gen8+ as well (PSR Haswell+, GuC/DC Gen9+).
  ++ lib.optionals (!legacyIntel) [
    "nvme.noacpi=1" # Helps with NVMe power consumption
    "i915.enable_guc=2" # Enable GuC/HuC firmware loading
    "i915.enable_psr=1" # Panel Self Refresh for power savings
    "i915.enable_fbc=1" # Framebuffer compression
    "i915.fastboot=1" # Skip unnecessary mode sets at boot
    "i915.enable_dc=2" # Display power saving
  ];

  # Load the driver
  services.xserver.videoDrivers = [ "modesetting" ];

  # OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver # i965 — covers Gen4–Gen7 (incl. HD 4000)
      libva-vdpau-driver
      libvdpau-va-gl
    ]
    ++ lib.optionals (!legacyIntel) [ intel-media-driver ]; # iHD — Gen8+ only
  };

  # Thermal and Noise Management
  services.thermald.enable = true;
  services.throttled.enable = true;
}
