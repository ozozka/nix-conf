{ pkgs, config, ... }:

let
  col = config.ozozka.theme.colors;
  settingsFormat = pkgs.formats.toml { };
  hex = v: "#" + v;
in
{
  imports = [ ../theme.nix ];

  environment = {
    systemPackages = with pkgs; [ alacritty ];

    etc."alacritty/alacritty.toml".source = settingsFormat.generate "alacritty.toml" {
      general = {
        live_config_reload = false;
      };

      window = {
        decorations = "None";
        opacity = col.tokens.t0;
        blur = col.tokens.blur;
      };

      scrolling = {
        history = 6000;
        multiplier = 6;
      };

      font = {
        normal = {
          family = config.ozozka.theme.fonts.mono;
          style = "Regular";
        };
        size = config.ozozka.theme.font-size.m / 10;
        offset = {
          x = 0;
          y = 4;
        };
      };

      colors = {
        primary = {
          foreground = hex col.tokens.f;
          background = hex col.tokens.b;
        };
        cursor = {
          text = hex col.tokens.b;
          cursor = hex col.tokens.f;
        };
        selection = {
          text = "CellForeground";
          background = hex col.tokens.o;
        };
        normal = {
          black = hex col.tokens.ansi0;
          red = hex col.tokens.ansi1;
          green = hex col.tokens.ansi2;
          yellow = hex col.tokens.ansi3;
          blue = hex col.tokens.ansi4;
          magenta = hex col.tokens.ansi5;
          cyan = hex col.tokens.ansi6;
          white = hex col.tokens.ansi7;
        };
        bright = {
          black = hex col.tokens.ansi8;
          red = hex col.tokens.ansi9;
          green = hex col.tokens.ansiA;
          yellow = hex col.tokens.ansiB;
          blue = hex col.tokens.ansiC;
          magenta = hex col.tokens.ansiD;
          cyan = hex col.tokens.ansiE;
          white = hex col.tokens.ansiF;
        };
      };

      selection = {
        save_to_clipboard = true;
      };

      cursor = {
        thickness = 0.12;
      };

      terminal = {
        osc52 = "CopyPaste";
      };

      mouse = {
        hide_when_typing = true;
      };
    };
  };
}
