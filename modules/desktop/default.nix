{ pkgs, ... }:

{
  imports = [
    ./emacs
    ./hyprland
    ./quickshell
    ./qutebrowser
    ./zen
    ./alacritty.nix
    ./fonts.nix
  ];

  security = {
    pam.services.login.enableGnomeKeyring = true;
    rtkit.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    # udisks2.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  programs = {
    thunar.enable = true;
  };

  environment = {
    sessionVariables = {
      XCURSOR_THEME = "DMZ-White";
      XCURSOR_SIZE = "24";
    };

    systemPackages = with pkgs; [
      mpv
      vanilla-dmz
      wl-clipboard
    ];
  };
}
