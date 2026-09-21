{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ mako ];

  systemd.user.services.mako = {
    description = "Mako notification daemon";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.mako}/bin/mako --config /etc/xdg/mako/config";
      Restart = "on-failure";
      Slice = "session.slice";
    };
  };

  environment.etc = {
    "xdg/mako/config".text = ''
      sort=+time
      layer=overlay
      font=Oziosevka 16px
      background-color=#000000E0
      border-radius=12
      width=420
      height=180
      margin=6
      padding=24
      border-size=0
      default-timeout=12000
      ignore-timeout=1
      max-visible=6
    '';
  };
}
