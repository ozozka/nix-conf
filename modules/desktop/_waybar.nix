{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    systemd.target = "graphical-session.target";
  };

  environment.etc = {
    "xdg/waybar/config.jsonc".source = (pkgs.formats.json { }).generate "waybar-config.jsonc" {
      layer = "top";
      position = "bottom";
      height = 24;
      width = 1920;
      spacing = 18;

      "modules-left" = [
        "hyprland/workspaces"
        "hyprland/language"
        "pulseaudio"
        "hyprland/submap"
      ];
      "modules-center" = [ "clock" ];
      "modules-right" = [
        "network"
        "temperature"
        "cpu"
        "memory"
        "battery"
      ];

      "hyprland/workspaces" = {
        format = " 🞄 ";
        persistent-workspaces = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
        };
      };
      "hyprland/language" = {
        format = "{short}";
      };
      pulseaudio = {
        scroll-step = 1;
        format = "{icon}%{volume}";
        format-muted = "{icon} - ";
        format-icons = {
          headphone = "🞄";
          hands-free = "▫";
          headset = "▪";
          default = "◦";
        };
      };
      "hyrpland/submap" = {
        format = "{}";
      };

      clock = {
        interval = 1;
        format = "{:%H:%M:%S}";
        format-alt = "{:%Y-%m-%d}";
        tooltip = false;
      };

      network = {
        interval = 1;
        format = "{bandwidthTotalBytes}{icon}";
        format-disconnected = "-";
        format-alt = "{bandwidthDownBytes} {bandwidthUpBytes}🠙 %{signalStrength}{icon}";
        format-icons = {
          wifi = "🞄";
          ethernet = "▪";
          linked = "◦";
        };
        tooltip-format = "{essid} - {ifname} = {ipaddr}/{cidr}";
      };
      temperature = {
        interval = 1;
        thermal-zone = 6;
        format = "{temperatureC}°C";
        tooltip = false;
      };
      cpu = {
        interval = 1;
        format = "%{usage}";
        format-alt = "{avg_frequency =0.2f} %{usage}";
        tooltip = false;
      };
      memory = {
        interval = 1;
        format = "{used:0.2f}";
        tooltip = false;
      };
      battery = {
        interval = 5;
        format-time = "{H} ={m}";
        format = "{time} %{capacity}◦";
        format-full = "🞄";
        format-charging = "{time} %{capacity}🞄";
      };
    };

    "xdg/waybar/style.css".text = ''
      @define-color bg #000000;
      @define-color bgs #100d14;
      @define-color fge #4e4a53;
      @define-color fg #ffffff;
      @define-color h1 #ff3a4c;

      * {
          font-family: Oziosevka;
          font-size: 16.2px;
          /* font-weight: 500; */

          text-shadow: none;
          box-shadow: none;
          transition: none;
          animation: none;
          border: none;
      }

      #window, window#waybar { background-color: @bg; color: @fg; }
      tooltip { opacity: 1; background-color: @bg; border-radius: 0; }
      tooltip * { color: @fg; }

      #workspaces { margin: 0; padding: 0; }
      #workspaces button { border-radius: 0; padding: 0; color: @fge; }
      workspaces button.empty { color: @bg; }
      #workspaces button.active { color: @fg; }
      /* #workspaces button:hover { background: @bgs; } */

      #battery { margin-right: 18px; }
    '';
  };
}
