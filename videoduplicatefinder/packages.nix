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
    version = "3.0.0";
    rev = "e8148a92f3d34265742c4999ee886dc5a05f13db";
    shortrev = builtins.substring 0 7 rev;
  in {
    packages = {
      videoduplicatefinder = pkgs.buildDotnetModule {
        inherit projectFile dotnet-sdk dotnet-runtime;
        pname = "videoduplicatefinder";
        version = "${version}+git-${shortrev}";
        src = src;
        nugetDeps = ./nix/deps.json; # run `nix build .#default.passthru.fetch-deps && ./result` and put the result here
        packNupkg = false;
        executables = ["VDF.GUI" "VDF.Web" "vdf-cli"];
        runtimeDeps = [pkgs.ffmpeg];

        doCheck = false;
        disabledTests = ["VDF.Core.Tests.Chromaprint.FftServiceTests.Forward_PureSineWave_PeakAtExpectedBin"];
      };
    };
    devShells = let
      commonSetup = ''
        echo "Read-only project source is in: $src"
        TMPDIR=`${pkgs.coreutils}/bin/mktemp -d`
        echo "Copying to $TMPDIR..."
        cp -r "$src/"* "$TMPDIR/" || true
        cp -r "$src/".* "$TMPDIR/" || true
        echo "Adjusting permissions..."
        ${pkgs.coreutils}/bin/chmod ug+w -R $TMPDIR
      '';
    in {
      videoduplicatefinder = pkgs.mkShell {
        buildInputs = [dotnet-sdk pkgs.git pkgs.alejandra];
        src = src;
        shellHook = ''
          ${commonSetup}
          cd "$TMPDIR"
        '';
      };
      videoduplicatefinder_fetch-deps = pkgs.mkShell {
        buildInputs = [dotnet-sdk pkgs.nuget-to-json];
        src = src;
        shellHook = ''
          ${commonSetup}
          OLDPWD=`pwd`
          cd "$TMPDIR"
          dotnet restore --packages out && \
          nuget-to-json out > deps.json && \
          echo && echo "GENERATED: $TMPDIR/deps.json"
          cd "$OLDPWD"
          exit
        '';

      };

    };
  };
}
