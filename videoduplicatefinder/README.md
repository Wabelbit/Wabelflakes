# videoduplicatefinder by 0x90d

https://github.com/0x90d/videoduplicatefinder

This flake module defines:

* `nix shell .#videoduplicatefinder` to make the applications `vdf-cli`, `VDF.GUI` and `VDF.Web` available.
* `nix develop .#videoduplicatefinder --command alejandra videoduplicatefinder` to run the [Alejandra](https://github.com/kamadorueda/alejandra) Nix source formatter.
* `nix build .#default.passthru.fetch-deps && ./result nix/deps.json` to collect the [NuGet] dependencies of the project into a [lockfile](./nix/deps.nix). (You only have to run this after you change the NuGet dependencies of the .NET projects.)
* `nix develop . --command dotnet restore .analyzers/analyzers.fsproj && nix run .#fsharp-analyzers -- --project ./HelloWorld/HelloWorld.fsproj --analyzers-path ./.analyzerpackages/g-research.fsharp.analyzers/*/` to run an opinionated set of F# analyzers.

## Development

When you want to add a [NuGet] dependency, you will have to rerun `nix build .#default.passthru.fetch-deps ** ./result`, whose final line of output will tell you which file in your machine's temporary storage it's written its output to.
Copy that file to `./nix/deps.nix`.
If you forget to do this, you'll see `nix build` fail at the NuGet restore stage, because it's not talking to NuGet but instead is using the dependencies present in the Nix store; if you haven't run `fetch-deps`, those dependencies will not be in the store.
(Note that the file as generated does not conform to Alejandra's formatting requirements, so you will probably also want to `nix develop . --command alejandra .` afterwards.)

[NuGet](https://www.nuget.org)
