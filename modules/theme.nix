{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.ozozka.theme;

  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };

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
    };
  };
in
{
  imports = [ ./overlays.nix ];

  options.ozozka.theme = {
    wallpaper =
      mkOpt lib.types.path "${pkgs.ozozka.ozozka-assets}/share/wallpapers/swirls.jpg"
        "Wallpaper image.";

    colors = {
      variant = mkOpt (lib.types.enum (lib.attrNames tokens)) "dark" "Color theme variant.";
      palette = mkOpt lib.types.attrs {
        p1 = "09bea8"; # oklch(0.72 0.1296 180)
        p0 = "026f61"; # oklch(0.486 0.0876 180)

        s1 = "ff3c5b"; # oklch(0.66 0.228 18)
        s0 = "c30d3a"; # oklch(0.522 0.204 18)

        w = "ffffff"; # oklch(1 0.0042 180)
        o0 = "e4e8e7"; # oklch(0.928 0.0042 180)
        m = "7e8180"; # oklch(0.60 0.0042 180)
        o1 = "101212"; # oklch(0.18 0.0042 180)
        b = "000000"; # oklch(0 0.0042 180)
      } "Colors.";
      tokens = mkOpt lib.types.attrs { } "Default colors according to my.theme.variant.";
    };

    # ansi-primary = "6";
    # ansi-secondary = "1";
    # ansi-foreground = "15";
    # ansi-muted = "7";
    # ansi-overlay = "8";
    # ansi-background = "0";

    fonts = {
      sans = mkOpt lib.types.str "Inter" "Sans font.";
      serif = mkOpt lib.types.str "Manuale" "Serif font.";
      mono = mkOpt lib.types.str "Oziosevka" "Monospace font.";
      emoji = mkOpt lib.types.str "Noto Color Emoji" "Emoji font.";
    };

    font-size = {
      t = mkOpt lib.types.int 60 "Tiny font size";
      s = mkOpt lib.types.int 90 "Small font size";
      m = mkOpt lib.types.int 120 "Medium font size";
      l = mkOpt lib.types.int 150 "Large font size";
      x = mkOpt lib.types.int 180 "Extra font size";
      h = mkOpt lib.types.int 240 "Huge font size";
    };

    dim = {
      t = mkOpt lib.types.int 3 "Tiny";
      s = mkOpt lib.types.int 12 "Small";
      m = mkOpt lib.types.int 24 "Medium";
      l = mkOpt lib.types.int 72 "Large";
      x = mkOpt lib.types.int 144 "Extra";
      h = mkOpt lib.types.int 360 "Huge";
    };
  };

  config.ozozka.theme.colors.tokens = lib.mkDefault tokens.${cfg.colors.variant};
}
