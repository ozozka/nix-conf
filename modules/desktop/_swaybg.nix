{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ swaybg ];

  systemd.user.services.swaybg = {
    description = "swaybg service";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i /etc/nixos/assets/wallpaper/horizon.jpg -m fill"; # tree.jpg, pompeii.png, lit-up-sky.png, mountain-range.jpg
      Restart = "on-failure";
      Slice = "session.slice";
    };
  };
}
