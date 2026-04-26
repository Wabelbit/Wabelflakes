# videoduplicatefinder by 0x90d

https://github.com/0x90d/videoduplicatefinder

This flake module defines:

* `nix shell .#videoduplicatefinder` to make the applications `vdf-cli`, `VDF.GUI` and `VDF.Web` available.
* `nix develop .#videoduplicatefinder` to start an interactive development shell.
* `nix develop .#videoduplicatefinder --command alejandra videoduplicatefinder` to run the [Alejandra](https://github.com/kamadorueda/alejandra) Nix source formatter.
* `nix develop .#videoduplicatefinder_fetch-deps` to collect the NuGet dependencies of the project into a [lockfile](./nix/deps.nix).
