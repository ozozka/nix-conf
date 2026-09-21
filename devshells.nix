{ pkgs }:
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
        ty
      ];
    };
  };

  inherit (pkgs) lib;
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
