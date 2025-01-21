{
  description = "web dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        mkNodeShell =
          { node_pkg, core_pkg }:
          pkgs.mkShell {
            name = "web-dev";

            buildInputs = with pkgs; [
              node_pkg
              core_pkg
              yarn
              pnpm
              bun
              deno
            ];

            # broken until nix flake doesn't support chaging default shell
            # shellHook = ''
            #   source <(deno completions zsh)
            #   source <(bun completions)
            #   source <(pnpm completion zsh)
            # '';
          };
      in
      {
        devShells = {
          default = mkNodeShell {
            node_pkg = pkgs.nodejs-slim;
            core_pkg = pkgs.corepack;
          };
          v20 = mkNodeShell {
            node_pkg = pkgs.nodejs-slim_20;
            core_pkg = pkgs.corepack_20;
          };
          v18 = mkNodeShell {
            node_pkg = pkgs.nodejs-slim_18;
            core_pkg = pkgs.corepack_18;
          };
          v16 = mkNodeShell {
            node_pkg = pkgs.nodejs-slim_16;
            core_pkg = pkgs.corepack_16;
          };
        };
      }
    );
}
