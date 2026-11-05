{self, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.taiko-rs = let
      pname = "taiko-rs";
      version = "cd169d3";
      src = pkgs.fetchurl {
        url = "https://github.com/Lynerrr/taiko-rs/releases/download/latest/taiko-rs-linux-x64.tar.gz";
        hash = "sha256-CdD/RtePeAapJGElmoaFUTwQkqCOfHBq4/TQvT0lIH4=";
      };
      # winit/wgpu dlopen these at runtime; autoPatchelf only covers DT_NEEDED.
      runtimeLibs = with pkgs; [
        alsa-lib
        libGL
        libx11
        libxcursor
        libxext
        libxi
        libxkbcommon
        libxrandr
        pipewire
        stdenv.cc.cc.lib
        vulkan-loader
        wayland
      ];
    in
      pkgs.stdenv.mkDerivation {
        inherit pname version src;

        nativeBuildInputs = [pkgs.autoPatchelfHook pkgs.copyDesktopItems pkgs.makeWrapper];
        buildInputs = runtimeLibs;

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "taiko-rs";
            desktopName = "taiko.rs";
            exec = "taiko-rs %u";
            icon = "taiko-rs";
            comment = "Optimized osu!taiko client";
            categories = ["Game"];
            mimeTypes = ["x-scheme-handler/taiko-rs"];
          })
        ];

        dontConfigure = true;
        dontBuild = true;
        dontStrip = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 taiko-rs $out/bin/taiko-rs
          wrapProgram $out/bin/taiko-rs \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
          install -Dm644 taiko-rs.png $out/share/icons/hicolor/256x256/apps/taiko-rs.png
          runHook postInstall
        '';

        meta = {
          description = "Optimized osu!taiko client";
          homepage = "https://rstaiko.auneu.space";
          license = lib.licenses.mit;
          sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
          mainProgram = "taiko-rs";
          platforms = ["x86_64-linux"];
        };
      };
  };

  flake.nixosModules.taiko-rs = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.programs.taiko-rs = {
      enable = lib.mkEnableOption "taiko.rs (osu!taiko client)";
    };
    config = lib.mkIf config.programs.taiko-rs.enable {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.taiko-rs
      ];
    };
  };
}
