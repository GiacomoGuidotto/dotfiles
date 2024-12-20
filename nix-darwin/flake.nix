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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # packages installed in system profile.
      # to search by name: $ nix-env -qaP | grep vim
      environment.systemPackages = with pkgs; [
        nixd
        nil
        stow
        lazygit
        lazydocker
        neofetch
        neovim
        zed-editor
        vim
      ];

      # set git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # used for backwards compatibility
      # please read the changelog before changing:
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # the platform the configuration will be used on
      nixpkgs.hostPlatform = "aarch64-darwin";

      # home-manager external configuration
      users.users.giacomo.home = "/Users/giacomo";
      home-manager.backupFileExtension = "backup";

      # nix configuration
      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      nix.useDaemon = true;

      # other pprograms
      programs.zsh.enable = true;
    };
  in
  {
    # build darwin flake:
    # $ darwin-rebuild build --flake ./nix-darwin#main
    darwinConfigurations.main = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.giacomo = import ./home.nix;
        }
      ];
    };
  };
}