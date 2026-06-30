# Einstiegspunkt für das gesamte NixOS-System.
# Hier werden alle externen Abhängigkeiten (nixpkgs, Home Manager, Stylix) versioniert
# und zu einer einzigen System-Konfiguration ("melbook") zusammengefasst.
{
  description = "melbook NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # Immer dieselbe nixpkgs-Version wie das System verwenden, kein zweiter Download.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }: {
    nixosConfigurations.melbook = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          # useGlobalPkgs/useUserPackages vermeiden doppelte Paket-Evaluierung.
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.users.mel        = import ./home/default.nix;
        }
      ];
    };
  };
}
