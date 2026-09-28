{ inputs }:

inputs.nixpkgs.lib.nixosSystem {
  modules = with inputs.self.nixosModules; [
    ./hardware-configuration.nix

    base
    desktop

    hardware-brightness
    hardware-nvidia
    hardware-swap
    hardware-wifi
    hardware-bluetooth

    # misc-chatgpt
    # misc-obs
    misc-gimp
    misc-loc
    misc-lsp
    misc-steam
    misc-pi
    misc-office

    {
      system.stateVersion = "25.11";
      networking.hostName = "ouz";

      specialisation = {
        # Uses integrated gpu and laptop monitor
        mobile = {
          inheritParentConfig = true;
          configuration = {
            system.nixos.tags = [ "mobile" ];

            # my.desktop.external = lib.mkForce false;
          };
        };
      };

      users.users.ouz = {
        isNormalUser = true;
        description = "ouz";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      ozozka.home.users = {
        ouz = {
          emacs = true;
          opencode = true;
          qutebrowser = true;
        };
      };
    }
  ];
}
