{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ vanilla-dmz ];
    sessionVariables = {
      XCURSOR_THEME = "DMZ-White";
      XCURSOR_SIZE = "24";
    };
  };
}
