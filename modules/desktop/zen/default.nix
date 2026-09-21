{ config, pkgs, ... }:

let
  theme = config.ozozka.theme;
  profile = "ouz";
in
{
  imports = [
    ../../theme.nix
    ../../overlays.nix
  ];

  environment.systemPackages = with pkgs; [ ozozka.zen-browser ];

  ozozka.home.profiles.zen-browser.files = {
    ".config/zen/${profile}/chrome/userChrome.css".source = ./userChrome.css;
    ".config/zen/${profile}/chrome/ozozka-theme.css".source = pkgs.writeText "oz-theme.css" ''
      :root {
        --oz-col-p: #${theme.colors.tokens.p};
        --oz-col-s: #${theme.colors.tokens.s};
        --oz-col-f: #${theme.colors.tokens.f};
        --oz-col-m: #${theme.colors.tokens.m};
        --oz-col-o: #${theme.colors.tokens.o};
        --oz-col-b: #${theme.colors.tokens.b};
        --oz-font-sans: "${theme.fonts.sans}";
      }
    '';

    ".config/zen/profiles.ini".source = ./profiles.ini;
  };
}
