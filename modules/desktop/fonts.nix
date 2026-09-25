{ pkgs, config, ... }:

let
  cfg = config.ozozka.theme.fonts;
in
{
  imports = [ ../theme.nix ];

  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      noto-fonts-color-emoji
      ozozka.spectral
      ozozka.manuale
      source-sans
      inter
      ozozka.oziosevka
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        emoji = [ cfg.emoji ];
        serif = [ cfg.serif ];
        sansSerif = [ cfg.sans ];
        monospace = [ cfg.mono ];
      };

      useEmbeddedBitmaps = false;
      antialias = true;
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
  };
}
