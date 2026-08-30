{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, lib, ...}@args: let
    wabellib = import ../lib.nix args;
    src = inputs.videoduplicatefinder;
    pname = "videoduplicatefinder";
    projectFile = "./VideoDuplicateFinder.sln";
    dotnet-sdk = pkgs.dotnet-sdk_10;
    #dotnet-runtime = pkgs.dotnetCorePackages.runtime_10_0;
    version = "4.1.0";
    rev = "51fbf0512002309e852e0e2e0a9eea0aba5bfba8";
    shortrev = builtins.substring 0 7 rev;
    fullVersion = "${version}+git-${shortrev}";
  in {
    packages = {
      videoduplicatefinder =
      ### WORKAROUND for build failure related to SkiaSharp, see https://github.com/NixOS/nixpkgs/issues/370827 ###
      let
      buildDotnetModule = pkgs.buildDotnetModule.override {
        addNuGetDeps = pkgs.dotnetCorePackages.addNuGetDeps.override {
          fetchNupkg = pkgs.dotnetCorePackages.fetchNupkg.override {
            overrides = {
              "SkiaSharp.NativeAssets.Linux" = package: package.overrideAttrs (
                old:
                lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
                  nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.autoPatchelfHook pkgs.stdenv.cc.cc.lib ];

                  buildInputs = old.buildInputs or [ ] ++ [ pkgs.fontconfig ];

                  preInstall = old.preInstall or "" + ''
                    cd runtimes
                    for platform in *; do
                      [[ $platform == "${pkgs.dotnetCorePackages.systemToDotnetRid pkgs.stdenv.hostPlatform.system}" ]] ||
                        rm -r "$platform"
                    done
                    cd - >/dev/null
                  '';
                }
              );
            };
          };
        };
      };
      ### END WORKAROUND ###
      in buildDotnetModule {
        inherit projectFile dotnet-sdk pname src;
        version = fullVersion;
        nugetDeps = ./nix/deps.json;
        packNupkg = false;
        executables = ["VDF.GUI" "VDF.Web" "vdf-cli"];
        runtimeDeps = [pkgs.ffmpeg];
        buildInputs = [];
        nativeBuildInputs = [pkgs.ffmpeg pkgs.git];
        enableParallelBuilding = false; # somehow parallel build causes random failures :(

        doCheck = true;
        disabledTests = [
          "VDF.Core.Tests.Chromaprint.FftServiceTests.Forward_PureSineWave_PeakAtExpectedBin"
          "VDF.Core.Tests.DriveScanPlannerTests.PartitionByDrive_GroupsCaseInsensitivelyAndKeepsStableOrder"
          "VDF.Core.Tests.DriveScanPlannerTests.Override_WinsAndSkipsTheProbe_KeyAndValueCaseInsensitive"
          "VDF.Core.Tests.DatabaseCountTests.CountsOnlyEntriesUnderTheFolder"
          "VDF.GUI.Tests.VersionConsistencyTests.BuiltAssemblyVersion_MatchesReleaseTag"
          # these tests have Windows paths hardcoded?!
          "VDF.GUI.Tests.DatabaseEditorRulesTests.Sort_BitrateReadsTheVideoStream"
          "VDF.GUI.Tests.DatabaseEditorRulesTests.Sort_FlagFirstPutsFlaggedEntriesOnTop_ThenBaseMode"
          "VDF.GUI.Tests.DatabaseEditorRulesTests.Sort_SizeLargestFirst_PathTiebreak"
          "VDF.Core.Tests.ClearCachedMediaDataTests.KeepsIdentityDataAndManualFlags"
          "VDF.Core.Tests.AI.FileEntryEmbeddingsTests.CurrentSchema_RoundTripsAndLoadsIntoEmbeddingsBuild"
        ];

        postInstall = ''
          install -Dm444 -T "$src/VDF.GUI/Assets/Linux/icon.png" "$out/share/icons/hicolor/256x256/apps/$pname.png"

          install -Dm555 -t "$out/share/applications" "${
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
          }/share/applications/$pname.desktop"
        '';

        meta = {
          homepage = "https://github.com/0x90d/videoduplicatefinder";
          description = "Video Duplicate Finder";
          license = lib.licenses.agpl3Only;
        };
      };
    };
    devShells = {
      videoduplicatefinder = pkgs.mkShell {
        inherit src;
        buildInputs = [dotnet-sdk pkgs.git pkgs.alejandra];
        shellHook = ''
          ${wabellib.devShells.commonSetup}

        '';
      };
      videoduplicatefinder_fetch-deps = pkgs.mkShell {
        inherit src;
        buildInputs = [dotnet-sdk pkgs.nuget-to-json];
        shellHook = ''
          OLDPWD=`pwd`
          ${wabellib.devShells.commonSetup}
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
