{
  description = "nix-darwin system flake";

  inputs = {
    # import nixpkgs flake with `unstable` channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # import nix-darwin flake
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # import home-manager flake
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
    }:
    let
      usr = "giacomo";

      # https://daiderd.com/nix-darwin/manual/index.html
      configuration =
        { pkgs, ... }:
        {
          # the platform the configuration will be used on
          nixpkgs.hostPlatform = "aarch64-darwin";

          # used for backwards compatibility
          # please read the changelog BEFORE changing:
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # set git commit hash for darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.primaryUser = usr;

          # system configuration
          system.defaults = {
            dock = {
              autohide = true;
              expose-group-apps = true;
              largesize = 16;
              magnification = false;
              mineffect = "genie";
              minimize-to-application = true;
              orientation = "bottom";
              persistent-apps = [ ];
              persistent-others = [ ];
              show-recents = false;
              tilesize = 36;
              wvous-tl-corner = 2; # mission control
              wvous-tr-corner = 12; # notification center
              wvous-bl-corner = 5; # start screensaver
              wvous-br-corner = 5; # start screensaver
            };

            finder = {
              AppleShowAllExtensions = true;
              AppleShowAllFiles = true;
              CreateDesktop = false;
              FXPreferredViewStyle = "Nlsv";
              QuitMenuItem = true;
              NewWindowTarget = "Home";
            };

            spaces.spans-displays = true;

            loginwindow.DisableConsoleAccess = false;

            NSGlobalDomain = {
              InitialKeyRepeat = 20;
              KeyRepeat = 2;
              ApplePressAndHoldEnabled = false;
              NSWindowShouldDragOnGesture = true;
              AppleInterfaceStyle = "Dark";
              _HIHideMenuBar = true;

              "com.apple.sound.beep.feedback" = 0;
              "com.apple.sound.beep.volume" = 0.0;
            };

            CustomUserPreferences = {
              "com.apple.HIToolbox" = {
                AppleEnabledInputSources = [
                  {
                    InputSourceKind = "Keyboard Layout";
                    "KeyboardLayout ID" = 223;
                    "KeyboardLayout Name" = "Italian - Pro";
                  }
                  {
                    InputSourceKind = "Keyboard Layout";
                    "KeyboardLayout ID" = 250;
                    "KeyboardLayout Name" = "British-PC";
                  }
                ];
                AppleSelectedInputSources = [
                  {
                    InputSourceKind = "Keyboard Layout";
                    "KeyboardLayout ID" = 250;
                    "KeyboardLayout Name" = "British-PC";
                  }
                ];
                AppleFnUsageType = 1; # change input source
                AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.British-PC";
                AppleDictationAutoEnable = 1;
              };

              "com.apple.AppleMultitouchTrackpad" = {
                ActuateDetents = 1;
                Clicking = 1;
                DragLock = 0;
                Dragging = 0;
                FirstClickThreshold = 1;
                ForceSuppressed = 0;
                HIDScrollZoomModifierMask = 0;
                SecondClickThreshold = 1;
                TrackpadCornerSecondaryClick = 0;
                TrackpadFiveFingerPinchGesture = 2;
                TrackpadFourFingerHorizSwipeGesture = 2;
                TrackpadFourFingerPinchGesture = 2;
                TrackpadFourFingerVertSwipeGesture = 2;
                TrackpadHandResting = 1;
                TrackpadHorizScroll = 1;
                TrackpadMomentumScroll = 1;
                TrackpadPinch = 1;
                TrackpadRightClick = 1;
                TrackpadRotate = 1;
                TrackpadScroll = 1;
                TrackpadThreeFingerDrag = 0;
                TrackpadThreeFingerHorizSwipeGesture = 2; # switch between full-screen apps
                TrackpadThreeFingerTapGesture = 0;
                TrackpadThreeFingerVertSwipeGesture = 2; # mission control
                TrackpadTwoFingerDoubleTapGesture = 1;
                TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
                USBMouseStopsTrackpad = 0;
              };
            };
          };

          # home-manager external configuration
          users.users.${usr}.home = "/Users/${usr}";

          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (pkgs.lib.getName pkg) [
              "cursor"
              "raycast"
              "spotify"
              "discord"
              "arc-browser"
              "signal-desktop"
              "pycharm-professional"
              "obsidian"
            ];

          # other programs
          services = {
            tailscale.enable = true;
            karabiner-elements.enable = false;
          };

          # workaround for karabiner-elements
          # nixpkgs.overlays = [
          #   (self: super: {
          #     karabiner-elements = super.karabiner-elements.overrideAttrs (old: {
          #       version = "14.13.0";

          #       src = super.fetchurl {
          #         inherit (old.src) url;
          #         hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
          #       };
          #     });
          #   })
          # ];

          # homebrew
          homebrew.enable = false;
        };
    in
    {
      # build darwin flake:
      # $ darwin-rebuild build --flake ./nix-darwin#main
      darwinConfigurations.main = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${usr} = import ./home.nix;
          }
        ];
      };
    };
}
