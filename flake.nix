{
  description = "ozozka's nix system config";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      lib = import ./lib.nix { inherit (nixpkgs) lib; };
      perSystem = lib.perSystem nixpkgs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      inherit lib;
      formatter = perSystem (pkgs: pkgs.callPackage ./formatter.nix { });
      checks = perSystem (pkgs: pkgs.callPackages ./checks.nix { inherit inputs; });
      devShells = perSystem (pkgs: pkgs.callPackages ./devshells.nix { });
      apps = perSystem (pkgs: import ./apps.nix { inherit pkgs; });
      packages = perSystem (pkgs: import ./pkgs { inherit pkgs; });
      overlays = import ./overlays;
      templates = import ./templates;
      nixosModules = lib.paths ./modules (path: path);
      nixosConfigurations = lib.paths ./hosts (path: import path { inherit inputs; });
    };
}
