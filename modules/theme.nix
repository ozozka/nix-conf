{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.ozozka.theme;

  tokens = {
    dark = rec {
      p = cfg.colors.palette.p1;
      s = cfg.colors.palette.s1;
      f = cfg.colors.palette.w;
      m = cfg.colors.palette.m;
      o = cfg.colors.palette.o1;
      b = cfg.colors.palette.b;

      ansi0 = b;
      ansi1 = s;
      ansi2 = p;
      ansi3 = p;
      ansi4 = s;
      ansi5 = s;
      ansi6 = p;
      ansi7 = m;
      ansi8 = o;
      ansi9 = s;
      ansiA = p;
      ansiB = p;
      ansiC = s;
      ansiD = s;
      ansiE = p;
      ansiF = f;

      ansi-primary = "6";
      ansi-secondary = "1";
      ansi-foreground = "15";
      ansi-muted = "7";
      ansi-overlay = "8";
      ansi-background = "0";

      t1 = 0.88;
      t0 = 0.94;
      hex-t1 = "e0"; # 88%
      hex-t0 = "f0"; # 94%

      blur = true;
    };
    light = rec {
      p = cfg.colors.palette.p0;
      s = cfg.colors.palette.s0;
      f = cfg.colors.palette.b;
      m = cfg.colors.palette.m;
      o = cfg.colors.palette.o0;
      b = cfg.colors.palette.w;

      ansi0 = b;
      ansi1 = s;
      ansi2 = p;
      ansi3 = p;
      ansi4 = s;
      ansi5 = s;
      ansi6 = p;
      ansi7 = m;
      ansi8 = o;
      ansi9 = s;
      ansiA = p;
      ansiB = p;
      ansiC = s;
      ansiD = s;
      ansiE = p;
      ansiF = f;

      ansi-primary = "6";
      ansi-secondary = "1";
      ansi-foreground = "15";
      ansi-muted = "7";
      ansi-overlay = "8";
      ansi-background = "0";

      t1 = 0.88;
      t0 = 0.94;
      hex-t1 = "e0"; # 88%
      hex-t0 = "f0"; # 94%

      blur = false;
    };
  };
in
{
  imports = [ ./overlays.nix ];

  options.ozozka.theme = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.ozozka.ozozka-assets}/share/wallpapers/horizon.jpg";
      description = "Wallpaper image.";
    };

    colors = {
      variant = lib.mkOption {
        type = lib.types.enum (lib.attrNames tokens);
        default = "dark";
        description = "Color theme variant.";
      };
      palette = lib.mkOption {
        type = lib.types.attrs;
        default = {
          p1 = "09bea8"; # oklch(0.72 0.1296 180)
          p0 = "026f61"; # oklch(0.486 0.0876 180)

          s1 = "ff3c5b"; # oklch(0.66 0.228 18)
          s0 = "c30d3a"; # oklch(0.522 0.204 18)

          w = "ffffff"; # oklch(1 0.0042 180)
          o0 = "e4e8e7"; # oklch(0.928 0.0042 180)
          m = "7e8180"; # oklch(0.60 0.0042 180)
          o1 = "101212"; # oklch(0.18 0.0042 180)
          b = "000000"; # oklch(0 0.0042 180)
        };
        description = "Colors.";
      };
      tokens = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = ''
          Color tokens. Defaults are selected according to my.theme.variant.
        '';
      };
    };

    fonts = {
      sans = lib.mkOption {
        type = lib.types.str;
        default = "Inter";
        description = "Sans font.";
      };
      serif = lib.mkOption {
        type = lib.types.str;
        default = "Manuale";
        description = "Serif font.";
      };
      mono = lib.mkOption {
        type = lib.types.str;
        default = "Oziosevka";
        description = "Monospace font.";
      };
      emoji = lib.mkOption {
        type = lib.types.str;
        default = "Noto Color Emoji";
        description = "Emoji font.";
      };
    };

    font-size = {
      t = lib.mkOption {
        type = lib.types.int;
        default = 105;
        description = "Tiny font size.";
      };
      s = lib.mkOption {
        type = lib.types.int;
        default = 120;
        description = "Small font size.";
      };
      m = lib.mkOption {
        type = lib.types.int;
        default = 150;
        description = "Medium font size.";
      };
      l = lib.mkOption {
        type = lib.types.int;
        default = 180;
        description = "Large font size.";
      };
      x = lib.mkOption {
        type = lib.types.int;
        default = 240;
        description = "Extra font size.";
      };
      h = lib.mkOption {
        type = lib.types.int;
        default = 270;
        description = "Huge font size.";
      };
    };

    dim = {
      t = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Tiny dim.";
      };
      s = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Small dim.";
      };
      m = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Medium dim.";
      };
      l = lib.mkOption {
        type = lib.types.int;
        default = 72;
        description = "Large dim.";
      };
      x = lib.mkOption {
        type = lib.types.int;
        default = 144;
        description = "Extra dim.";
      };
      h = lib.mkOption {
        type = lib.types.int;
        default = 360;
        description = "Huge dim.";
      };
    };
  };

  config.ozozka.theme.colors.tokens = lib.mkDefault tokens.${cfg.colors.variant};
}
