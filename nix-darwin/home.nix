{ pkgs, lib, ... }:

# https://daiderd.com/nix-darwin/manual/index.html
# https://home-manager-options.extranix.com/release=master
{
  # nix configuration
  nix = {
    settings = {
      warn-dirty = false;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;

      # Keep last 3 generations
      options = "--delete-older-than +3";
    };
  };

  home.username = "giacomo";
  home.homeDirectory = "/Users/giacomo";
  xdg.enable = true;

  # home-manager version
  # used for backwards compatibility
  # please check release notes BEFORE changing:
  home.stateVersion = "24.11";

  # packages installed in user profile.
  home.packages = with pkgs; [
    # nix internals
    nixd
    nil
    nixfmt-rfc-style

    # sdks
    nodejs-slim # needed for gh copilot
    texliveFull
    tex-fmt

    # desktop environment
    aerospace

    # terminals
    # ghostty

    # shells
    nushell

    # cli tools
    azure-cli
    atuin
    bat
    btop
    carapace
    delta
    eza
    fd
    fzf
    git
    jankyborders
    kubectl
    kubectx
    k9s
    lazydocker
    lazygit
    neofetch
    nmap
    ripgrep
    starship
    stow
    tree
    xh
    watchman
    ollama
    yazi
    zoxide
    zellij

    # editors
    neovim
    zed-editor
    code-cursor
    # jetbrains.pycharm-professional

    # docker
    colima
    docker-client
    docker-compose

    # apps
    arc-browser
    discord
    mas
    raycast
    spotify
    # signal-desktop # not available on aarch64-apple-darwin
    obsidian
    # vlc # not available on aarch64-apple-darwin

    # nerd fonts
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.zed-mono
  ];

  # programs managed by home-manager
  programs = {
    home-manager.enable = true;

    zsh.enable = true;
    zsh.enableCompletion = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # simlinks of files copied to the Nix store.
  # source path is relative to the flake root.
  home.file = {
    # ".config/nvim" = {
    #   source = ../nvim;
    #   recursive = true;
    # };

    ".condarc".source = ../conda/.condarc;
    ".hushlogin".text = "";
    ".zshrc".source = ../zsh/.zshrc;
    # ".zprofile".source = ../zsh/.zprofile;
  };

  # session variables
  # available only if using a home-manager shell
  home.sessionVariables = {
    EDITOR = "nvim";
    REACT_EDITOR = "nvim";

    # used to tell lazygit to use delta as pager (https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md#using-git-config)
    GIT_PAGER = "delta";

    # remove the direnv log when cd
    DIRENV_LOG_FORMAT = "";

    # override the default starship config path
    STARSHIP_CONFIG = "$HOME/.config/starship/config.toml";

    # set the docker host to the colima socket
    DOCKER_HOST = "unix://$HOME/.config/colima/docker.sock";
  };

  # custom daemons
  launchd.agents = {
    ollama = {
      enable = false;
      config = {
        ProgramArguments = [
          "${pkgs.ollama}/bin/ollama"
          "serve"
        ];
        RunAtLoad = true;
        KeepAlive = true;
      };
    };
  };

  # scripts ran after home-manager activation
  home.activation = {
    installXCode = lib.hm.dag.entryAfter [ "home.packages" ] ''
      ${pkgs.mas}/bin/mas install 497799835 2> /dev/null
    '';
    installWhatsApp = lib.hm.dag.entryAfter [ "home.packages" ] ''
      ${pkgs.mas}/bin/mas install 310633997 2> /dev/null
    '';
    # # not working: sudo: command not found
    # setupDisplaySleep = ''
    #   sudo /usr/bin/pmset -b displaysleep 20
    # '';
  };
}
