{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.ozozka.theme;

  quickshellSource = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./components
      ./lib
      ./modules
      ./services
      ./shell.qml
      ./qmldir
    ];
  };

  themeQml = pkgs.writeTextDir "T.qml" ''
    pragma Singleton

    import Quickshell
    import QtQuick

    Singleton {
      readonly property color colP: ${builtins.toJSON "#${theme.colors.tokens.p}"}
      readonly property color colS: ${builtins.toJSON "#${theme.colors.tokens.s}"}
      readonly property color colF: ${builtins.toJSON "#${theme.colors.tokens.f}"}
      readonly property color colM: ${builtins.toJSON "#${theme.colors.tokens.m}"}
      readonly property color colO: ${builtins.toJSON "#${theme.colors.tokens.o}"}
      readonly property color colB: ${builtins.toJSON "#${theme.colors.tokens.b}"}

      readonly property real fontSizeB: ${toString (theme.font-size.m / 10.0)}
      readonly property real fontSizeH: ${toString (theme.font-size.l / 10.0)}
      readonly property real fontSizeT: ${toString (theme.font-size.h / 10.0)}

      readonly property int spaceS: ${toString theme.dim.s}
      readonly property int spaceM: ${toString (theme.dim.s * 2)}
      readonly property int spaceL: ${toString theme.dim.m}
      readonly property int dimH: ${toString theme.dim.h}

      readonly property string wallpaper: ${builtins.toJSON (toString theme.wallpaper)}
    }
  '';

  quickshellConfig = pkgs.symlinkJoin {
    name = "quickshell-config";
    paths = [
      quickshellSource
      themeQml
    ];
  };
in
{
  imports = [ ../../theme.nix ];

  environment = {
    systemPackages = with pkgs; [
      quickshell
      gtk3
    ];
    etc."xdg/quickshell".source = quickshellConfig;
  };

  systemd.user.services.quickshell = {
    description = "Quickshell";

    enableDefaultPath = false;

    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    unitConfig.ConditionPathExists = "/etc/xdg/quickshell/shell.qml";

    serviceConfig = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 5;
      Slice = "session.slice";
    };
  };

  security = {
    polkit.enable = true;
    pam.services.quickshell = { };
  };
}
