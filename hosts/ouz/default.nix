{ inputs }:

inputs.nixpkgs.lib.nixosSystem {
  modules = with inputs.self.nixosModules; [
    ./hardware-configuration.nix

    base
    desktop
    dev

    hardware-brightness
    hardware-nvidia
    hardware-swap
    hardware-wifi
    hardware-bluetooth

    # misc-obs
    misc-gimp
    misc-steam
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

      fileSystems."/ozozka" = {
        device = "/dev/disk/by-uuid/75bc2a26-dd71-4dde-b1ed-1bb86246bde4";
        fsType = "ext4";
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
          pi = true;
          qutebrowser = true;
        };
      };
    }
  ];
}
