{
  config,
  lib,
  pkgs,
  ...
}:

let
  theme = config.ozozka.theme;

  themeQml = pkgs.replaceVars ./T.qml.in {
    colP = builtins.toJSON "#${theme.colors.tokens.p}";
    colS = builtins.toJSON "#${theme.colors.tokens.s}";
    colF = builtins.toJSON "#${theme.colors.tokens.f}";
    colM = builtins.toJSON "#${theme.colors.tokens.m}";
    colO = builtins.toJSON "#${theme.colors.tokens.o}";
    colB = builtins.toJSON "#${theme.colors.tokens.hex-t1}${theme.colors.tokens.b}";
    fontSans = builtins.toJSON theme.fonts.sans;
    fontSerif = builtins.toJSON theme.fonts.serif;
    fontMono = builtins.toJSON theme.fonts.mono;
    fontSizeB = toString (theme.font-size.m / 10.0);
    fontSizeH = toString (theme.font-size.l / 10.0);
    fontSizeT = toString (theme.font-size.h / 10.0);
    spaceS = toString theme.dim.s;
    spaceM = toString (theme.dim.s * 2);
    spaceL = toString theme.dim.m;
    blur = lib.boolToString theme.colors.tokens.blur;
    wallpaper = builtins.toJSON (toString theme.wallpaper);
  };

  quickshellConfig = pkgs.runCommand "quickshell-config" { } ''
    mkdir -p "$out"
    cp -r ${./components} "$out/components"
    cp -r ${./lib} "$out/lib"
    cp -r ${./modules} "$out/modules"
    cp -r ${./services} "$out/services"
    cp -r ${./widgets} "$out/widgets"
    cp ${./shell.qml} "$out/shell.qml"
    cp ${./qmldir} "$out/qmldir"
    cp ${themeQml} "$out/T.qml"
  '';
in
{
  imports = [ ../../theme.nix ];

  environment = {
    systemPackages = with pkgs; [ quickshell ];
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
