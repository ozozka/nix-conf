{ config, pkgs, ... }:

let
  theme = config.ozozka.theme;
in
{
  imports = [ ../../theme.nix ];

  environment = {
    systemPackages = with pkgs; [
      quickshell
      gtk3
    ];

    etc = {
      "xdg/quickshell/shell.qml".source = ./shell.qml;
      "xdg/quickshell/Bar.qml".source = ./Bar.qml;
      "xdg/quickshell/Menu.qml".source = ./Menu.qml;
      "xdg/quickshell/Notification.qml".source = ./Notification.qml;
      "xdg/quickshell/Lock.qml".source = ./Lock.qml;
      "xdg/quickshell/Polkit.qml".source = ./Polkit.qml;
      "xdg/quickshell/Wallpaper.qml".source = ./Wallpaper.qml;
      "xdg/quickshell/Lib.qml".source = ./Lib.qml;
      "xdg/quickshell/T.qml".text = ''
        import QtQuick

        QtObject {
          readonly property color colP: ${builtins.toJSON "#${theme.colors.tokens.p}"}
          readonly property color colS: ${builtins.toJSON "#${theme.colors.tokens.s}"}
          readonly property color colF: ${builtins.toJSON "#${theme.colors.tokens.f}"}
          readonly property color colM: ${builtins.toJSON "#${theme.colors.tokens.m}"}
          readonly property color colO: ${builtins.toJSON "#${theme.colors.tokens.o}"}
          readonly property color colB: ${builtins.toJSON "#${theme.colors.tokens.b}"}

          readonly property real fontSizeT: ${toString (theme.font-size.t / 10.0)}
          readonly property real fontSizeS: ${toString (theme.font-size.s / 10.0)}
          readonly property real fontSizeM: ${toString (theme.font-size.m / 10.0)}
          readonly property real fontSizeL: ${toString (theme.font-size.l / 10.0)}
          readonly property real fontSizeX: ${toString (theme.font-size.x / 10.0)}
          readonly property real fontSizeH: ${toString (theme.font-size.h / 10.0)}

          readonly property int dimT: ${toString theme.dim.t}
          readonly property int dimS: ${toString theme.dim.s}
          readonly property int dimM: ${toString theme.dim.m}
          readonly property int dimL: ${toString theme.dim.l}
          readonly property int dimX: ${toString theme.dim.x}
          readonly property int dimH: ${toString theme.dim.h}

          readonly property string wallpaper: ${builtins.toJSON (toString theme.wallpaper)}
        }
      '';
    };
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
