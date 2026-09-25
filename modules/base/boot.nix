{ pkgs, config, ... }:

let
  theme = config.ozozka.theme;
in
{
  imports = [ ../theme.nix ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 3;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;

      font = "${pkgs.ozozka.oziosevka}/share/fonts/truetype/IosevkaOziosevka-Regular.ttf";
      fontSize = theme.font-size.x * 4 / 30;

      configurationLimit = 12;
      timeoutStyle = "menu";

      extraConfig = ''
        set gfxmode=auto
        set gfxpayload=keep
      '';

      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';

      theme = pkgs.writeTextDir "theme.txt" ''
        desktop-color: "#${theme.colors.tokens.b}"
        title-text: "naber"
        + boot_menu {
          left = 16%
          top = 20%
          width = 68%
          height = 60%

          item_color = "#${theme.colors.tokens.m}"
          selected_item_color = "#${theme.colors.tokens.f}"
          item_height = 60
          item_padding = 6
          item_spacing = 12
        }
      '';
    };
  };
}
