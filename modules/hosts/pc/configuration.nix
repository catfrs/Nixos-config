{self, ...}: {
  flake.nixosModules.pcConfiguration = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      # Include the results of the hardware scan.
      self.nixosModules.pcHardware
      self.nixosModules.cursor
      self.nixosModules.zen
    ];

     environment.shellAliases = {
      ns = "sudo nixos-rebuild switch --flake ~/yuri#pc";
      nt = "sudo nixos-rebuild test --flake ~/yuri#pc";
      nb = "sudo nixos-rebuild build --flake ~/yuri#pc";
    };

    networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Paris";

    # Select internationalisation properties.
    i18n.defaultLocale = "fr_FR.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = false;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "fr";
      variant = "azerty";
    };

    # Configure console keymap
    console.keyMap = "fr";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."catfr" = {
      isNormalUser = true;
      description = "chat";
      extraGroups = ["networkmanager" "wheel"];
      packages = with pkgs; [
        kdePackages.kate
        vesktop
        steam
        protonup-qt
        osu-lazer-bin
        prismlauncher
        heroic
        krita
        pinta
        spotify
        git
        vscode-fhs
      ];
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];

    hardware.opentabletdriver.enable = true;

    # Install firefox.
    programs.firefox.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
      fastfetch
      ntfs3g
    ];

    # MIPS
    boot = {
      consoleLogLevel = 3;
      kernelPackages = pkgs.linuxPackages_zen;

      initrd = {
        systemd.enable = true;
        verbose = false;
      };

      kernel.sysctl = {
        "vm.swappiness" = 10;
      };

      kernelParams = [
        "boot.shell_on_fail"
        "intremap=on"
        "quiet"
        "rd.systemd.show_status=auto"
        "splash"
        "udev.log_priority=3"
      ];

      loader = {
        systemd-boot = {
          consoleMode = "max";
          enable = true;
        };
        efi = {
          canTouchEfiVariables = true;
        };
      };

      plymouth = {
        enable = true;
        font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
        logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake-white.png";
        theme = "bgrt";
      };
    };

    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };

    fileSystems."/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["mode=1777" "size=4G"];
    };

    # Nvidia

    # Enable OpenGL
    hardware.graphics = {
      enable32Bit = true;
      enable = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.nvidia.prime = {
      sync.enable = true;
      # Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:1:0:0";
      nvidiaBusId = "PCI:6:0:0";
      # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
    };

    # ne change jamais ça
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
