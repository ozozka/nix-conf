{ config, pkgs, ... }:

let
  theme = config.ozozka.theme;
in
{
  imports = [
    ../../home.nix
    ../../theme.nix
  ];

  environment.systemPackages = with pkgs; [ qutebrowser ];

  ozozka.home.profiles.qutebrowser.files = {
    ".config/qutebrowser/config.py".source = ./config.py;
    ".config/qutebrowser/theme.py".source = pkgs.writeText "theme.py" ''
      COL_P = "#${theme.colors.tokens.p}"
      COL_S = "#${theme.colors.tokens.s}"
      COL_F = "#${theme.colors.tokens.f}"
      COL_M = "#${theme.colors.tokens.m}"
      COL_O = "#${theme.colors.tokens.o}"
      COL_B = "#${theme.colors.tokens.b}"

      FONTS_EMOJI = "${theme.fonts.emoji}"
      FONTS_SANS = "${theme.fonts.sans}"
      FONTS_SERIF = "${theme.fonts.serif}"
      FONTS_MONO = "${theme.fonts.mono}"

      FONT_SIZE_T = int(${toString (theme.font-size.t / 10.0)})
      FONT_SIZE_S = int(${toString (theme.font-size.s / 10.0)})
      FONT_SIZE_M = int(${toString (theme.font-size.m / 10.0)})
      FONT_SIZE_L = int(${toString (theme.font-size.l / 10.0)})
      FONT_SIZE_X = int(${toString (theme.font-size.x / 10.0)})
      FONT_SIZE_H = int(${toString (theme.font-size.h / 10.0)})

      DIM_T = ${toString theme.dim.t}
      DIM_S = ${toString theme.dim.s}
      DIM_M = ${toString theme.dim.m}
      DIM_L = ${toString theme.dim.l}
      DIM_X = ${toString theme.dim.x}
      DIM_H = ${toString theme.dim.h}
    '';
  };
}
