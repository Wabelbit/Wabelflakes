{
  description = "Collection of flakes to build tools not available in nixpkgs";

  inputs = {
    # deps
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # all modules with their respective source
    videoduplicatefinder = { url = "github:0x90d/videoduplicatefinder"; flake = false; };

  };

  outputs = { self, ... } @ inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      # import all modules
      ./videoduplicatefinder/packages.nix
    ];

    perSystem = { config, self', inputs', pkgs, system, ... }: {
    };

    flake = {
    };

    # Declared systems that your flake supports. These will be enumerated in perSystem
    systems = builtins.attrNames inputs.nixpkgs.legacyPackages;
  };
}
