{ pkgs, ... }: {
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };

  environment = {
    loginShellInit = ''
      if [ -z "$DISPLAY" ] \
        && [ -z "$WAYLAND_DISPLAY" ] \
        && [ "$(tty)" = "/dev/tty1" ] \
        && uwsm check may-start \
      ; then
        exec uwsm start hyprland.desktop
      fi
    '';

    etc = {
      "xdg/hypr/stubs".source = "${pkgs.hyprland}/share/hypr/stubs";
      "xdg/hypr/hyprland.lua".source = ./hyprland.lua;

      "xdg/hypr/hyprtoolkit.conf".source = ./hyprtoolkit.conf;
    };

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
