{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, lib, ...}: let
    src = inputs.videoduplicatefinder;
    pname = "videoduplicatefinder";
    projectFile = "./VideoDuplicateFinder.sln";
    dotnet-sdk = pkgs.dotnet-sdk_9;
    #dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;
    version = "3.0.0";
    rev = "729c7cb73a9b6003b069986468ecab94fd82ed22";
    shortrev = builtins.substring 0 7 rev;
    fullVersion = "${version}+git-${shortrev}";
  in {
    packages = {
      videoduplicatefinder = pkgs.buildDotnetModule {
        inherit projectFile dotnet-sdk;
        pname = pname;
        version = fullVersion;
        src = src;
        nugetDeps = ./nix/deps.json;
        packNupkg = false;
        executables = ["VDF.GUI" "VDF.Web" "vdf-cli"];
        runtimeDeps = [pkgs.ffmpeg];
        enableParallelBuilding = false; # somehow parallel build causes random failures :(

        doCheck = true;
        disabledTests = ["VDF.Core.Tests.Chromaprint.FftServiceTests.Forward_PureSineWave_PeakAtExpectedBin"];
        nativeBuildInputs = [pkgs.ffmpeg];

        postInstall = ''
          install -Dm444 -T "$src/VDF.GUI/Assets/Linux/icon.png" "$out/share/icons/hicolor/256x256/apps/$pname.png"

          install -Dm555 -t $out/share/applications ${
            pkgs.makeDesktopItem {
              name = pname;
              desktopName = "Video Duplicate Finder";
              genericName = "Duplicate File Finder";
              comment = "Find duplicate video and image files based on visual similarity";
              exec = "VDF.GUI";
              icon = pname;
              type = "Application";
              categories = ["Utility" "FileManager"];
              keywords=["duplicate" "video" "image" "finder" "similarity"];
              startupNotify = true;
            }
          }/share/applications/$pname.desktop
        '';

        meta = {
          homepage = "https://github.com/0x90d/videoduplicatefinder";
          description = "Video Duplicate Finder";
          license = lib.licenses.agpl3Only;
        };
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
          dotnet build && \
          echo && echo "GENERATED: $TMPDIR/deps.json"
          cd "$OLDPWD"
          exit
        '';

      };

    };
  };
}
