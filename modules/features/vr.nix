{...}: {
  flake.nixosModules.vr = {pkgs, ...}: {
    boot.kernelModules = ["uinput"];

    environment.systemPackages = with pkgs; [
      wayvr
    ];

    # Ports and avahi publishing are opened/configured by the service itself
    services.wivrn = {
      enable = true;
      openFirewall = true;

      # CAP_SYS_NICE, for asynchronous reprojection
      highPriority = true;

      # Steam OpenXR discovery
      steam.importOXRRuntimes = true;
      steam.package = pkgs.steam;

      config.enable = true;
      config.json = {
        application = [pkgs.wayvr];
        # hostname unset: WiVRn defaults to the system hostname
      };
    };
  };
}
