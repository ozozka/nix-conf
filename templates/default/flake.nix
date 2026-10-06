{
  description = "";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      perSystem =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = {
                allowUnfree = false;
              };
            }
          )
        );
    in
    {
      devShells = perSystem (
        pkgs:
        let
          base = {
            packages = with pkgs; [ just ];
            env = { };
            shellHook = "";
          };

          shells = {
            dev = {
              packages = with pkgs; [
                nixd
                lua-language-server
              ];
            };
          };

          inherit (builtins) attrValues;
        in
        builtins.mapAttrs
          (
            shellName: shell:
            pkgs.mkShell rec {
              LD_LIBRARY_PATH = lib.makeLibraryPath packages;
              packages = lib.unique (base.packages ++ (shell.packages or [ ]));
              env = (base.env or { }) // (shell.env or { });
              shellHook = lib.concatStringsSep "\n" [
                base.shellHook
                (shell.shellHook or "")
                ''echo "- ${shellName}"''
              ];
            }
          )
          (
            shells
            // {
              default = {
                packages = lib.unique (lib.flatten (map (s: s.packages or [ ]) (attrValues shells)));
                env = lib.foldl' (acc: env: acc // env) { } (map (s: s.env or { }) (attrValues shells));
                shellHook = lib.concatStringsSep "\n" (map (s: s.shellHook or "") (attrValues shells));
              };
            }
          )
      );

      formatter = perSystem (
        pkgs:
        pkgs.treefmt.withConfig {
          settings = {
            tree-root-file = "flake.nix";
            on-unmatched = "debug";

            formatter = {
              just = {
                command = pkgs.lib.getExe (
                  pkgs.writeShellApplication {
                    name = "justfmt";
                    runtimeInputs = [ pkgs.just ];
                    text = ''
                      for f in "$@"; do
                        just --fmt --justfile "$f"
                      done
                    '';
                  }
                );
                includes = [
                  "justfile"
                  "*/justfile"
                ];
              };

              prettier = {
                command = pkgs.lib.getExe pkgs.prettier;
                includes = [
                  "*.html"
                  "*.css"
                  "*.js"
                  "*.ts"
                  "*.md"
                ];
                options = [
                  "--write"
                  "--ignore-unknown"
                  "--tab-width=2"
                  "--semi=true"
                  "--single-quote=false"
                  "--trailing-comma=all"
                ];
              };

              nixf-diagnose = {
                command = pkgs.lib.getExe pkgs.nixf-diagnose;
                includes = [ "*.nix" ];
                options = [ "--auto-fix" ];
                priority = -2;
              };

              statix = {
                command = lib.getExe (
                  pkgs.writeShellApplication {
                    name = "statix-check";
                    runtimeInputs = [ pkgs.statix ];
                    text = ''
                      for file in "$@"; do
                        statix check "$file"
                      done
                    '';
                  }
                );
                includes = [ "*.nix" ];
                priority = -1;
              };

              nixfmt = {
                command = pkgs.lib.getExe pkgs.nixfmt;
                includes = [ "*.nix" ];
                options = [ "--strict" ];
              };
            };
          };
        }
      );

      checks = perSystem (
        pkgs:
        let
          formatter = pkgs.callPackage ./formatter.nix { };
          fs = lib.fileset;
          src = fs.toSource {
            root = ./.;
            fileset = fs.difference ./. (fs.maybeMissing ./.git);
          };
        in
        {
          format = formatter.check src;
        }
      );
    };
}
