{ inputs, pkgs, ... }:

let
  inherit (pkgs) lib;

  formatter = pkgs.callPackage ./formatter.nix { };
  fs = lib.fileset;
  src = fs.toSource {
    root = ./.;
    fileset = fs.difference ./. (fs.maybeMissing ./.git);
  };

  qmlTheme = pkgs.replaceVars ./modules/desktop/quickshell/T.qml.in {
    colP = ''"#000000"'';
    colS = ''"#000000"'';
    colF = ''"#000000"'';
    colM = ''"#000000"'';
    colO = ''"#000000"'';
    colB = ''"#000000"'';
    fontSans = ''""'';
    fontSerif = ''""'';
    fontMono = ''""'';
    fontSizeB = "0";
    fontSizeH = "0";
    fontSizeT = "0";
    spaceS = "0";
    spaceM = "0";
    spaceL = "0";
    blur = "false";
    wallpaper = ''""'';
  };

  moduleFixture = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    system.stateVersion = lib.mkDefault "25.11";

    fileSystems."/" = {
      device = lib.mkDefault "/dev/null";
      fsType = lib.mkDefault "ext4";
    };

    boot.loader.grub = {
      enable = lib.mkDefault true;
      device = lib.mkDefault "nodev";
    };
  };

  moduleChecks = lib.mapAttrs' (
    name: module:
    lib.nameValuePair "nixos-module-${name}" (
      let
        evaluated = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            moduleFixture
            module
          ];
        };

        drvPath = builtins.addErrorContext "while evaluating nixosModules.${name} independently" evaluated.config.system.build.toplevel.drvPath;
      in
      builtins.seq drvPath (
        pkgs.runCommand "nixos-module-${name}-check" { } ''
          touch "$out"
        ''
      )
    )
  ) inputs.self.nixosModules;

in
{
  format = formatter.check src;

  statix = pkgs.runCommand "statix-check" { nativeBuildInputs = [ pkgs.statix ]; } ''
    cd ${src}
    statix check .
    touch $out
  '';
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {

  qml =
    pkgs.runCommand "qml-check"
      {
        nativeBuildInputs = [
          pkgs.qt6.qtdeclarative
          pkgs.quickshell
        ];
      }
      ''
            cp -r ${src}/modules/desktop/quickshell quickshell
            chmod -R u+w quickshell

            cp ${qmlTheme} quickshell/T.qml

        qmllint \
          -I ${pkgs.qt6.qtdeclarative}/lib/qt-6/qml \
          -I ${pkgs.quickshell}/lib/qt-6/qml \
              --uncreatable-type disable \
              --unqualified disable \
              --unused-imports disable \
              --missing-property error \
              --property-override error \
              --missing-enum-entry error \
              --import error \
              --max-warnings 0 \
              quickshell/shell.qml
            touch $out
      '';
}
// lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") moduleChecks
