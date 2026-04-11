# Wabelflakes

My collection of Nix flakes for software that isn't available in nixpkgs and has no official flake

# Usage

## NixOS

Include the flake in your system flake:

```nix
wabelFlakes.url = "github:Wabelbit/Wabelflakes";
wabelFlakes.inputs.nixpkgs.follows = "nixpkgs";
```

Then install whatever you need, e.g.: `wabelFlakes.packages.x86_64-linux.videoduplicatefinder`

## Nix CLI

- View available packages: `nix flake show github:Wabelbit/Wabelflakes`
- Make desired programs available, e.g.: `nix shell github:Wabelbit/Wabelflakes#videoduplicatefinder`

