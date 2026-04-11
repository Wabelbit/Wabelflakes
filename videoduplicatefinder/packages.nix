{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, ...}: let
    src = inputs.videoduplicatefinder;
    projectFile = "./VideoDuplicateFinder.sln";
    dotnet-sdk = pkgs.dotnet-sdk_9;
    dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;
    version = "3.0.0+git-e2e3a8f";
  in {
    packages = {
      videoduplicatefinder = pkgs.buildDotnetModule {
        inherit projectFile dotnet-sdk dotnet-runtime;
        pname = "videoduplicatefinder";
        version = version;
        src = src;
        nugetDeps = ./nix/deps.json; # run `nix build .#default.passthru.fetch-deps && ./result` and put the result here
        packNupkg = false;
        executables = ["VDF.GUI" "VDF.Web" "vdf-cli"];
        runtimeDeps = [pkgs.ffmpeg];

        doCheck = false;
        disabledTests = ["VDF.Core.Tests.Chromaprint.FftServiceTests.Forward_PureSineWave_PeakAtExpectedBin"];
      };
    };
    devShells.videoduplicatefinder = pkgs.mkShell {
      buildInputs = [dotnet-sdk pkgs.git pkgs.alejandra];
      src = src;
      shellHook = ''
        echo "Read-only project source is in: $src"
      '';
    };
  };
}
