{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, lib, system, ...}@args: let
    oldPkgs = inputs.nixpkgsPlasma5.legacyPackages.${system};
    wabellib = import ../lib.nix args;
    src = inputs.ksysguard5;
    pname = "ksysguard5";
    version = "5.22.80";
    rev = "b41f9b29d50762b63008c80de7c99db97aa4a205";
    shortrev = builtins.substring 0 7 rev;
    fullVersion = "${version}+git-${shortrev}";
    buildTimeDeps = [oldPkgs.qt5.wrapQtAppsHook] ++ (with pkgs; [
      cmake
      ninja
      pkg-config
      python315
      libpcap
      libnl
      lm_sensors
      #moveOutputsHook
      #qmllintHook
    ]) ++ (with oldPkgs.plasma5Packages; [
      extra-cmake-modules
      qtbase
      qtdeclarative
      frameworkintegration
      knotifications
      kwindowsystem
      kconfigwidgets
      kglobalaccel
      kxmlgui
      knewstuff
      kdbusaddons
      kdoctools
      kio
      kauth
      libksysguard
      qtwebengine
      qtwebchannel
    ]);
  in {
    packages = {
      ksysguard5 = pkgs.stdenv.mkDerivation {
        inherit pname src;
        version = fullVersion;

        buildInputs = [ oldPkgs.qt5.qtbase ];
        nativeBuildInputs = buildTimeDeps;

        cmakeFlags = [ "-DQT_MAJOR_VERSION=5" ];
        doInstallCheck = true;
        separateDebugInfo = true;

        meta = {
          homepage = "https://apps.kde.org/ksysguard/";
          description = "The last officially published version of KSysGuard 5";
          license = lib.licenses.gpl2;
        };
      };
    };
    devShells = {
      ksysguard5 = let
        qtEnv = oldPkgs.qt5.env "qt5-simc-${oldPkgs.qt5.qtbase.version}" [
        oldPkgs.qt5.qtbase
        oldPkgs.qt5.qtwebengine
        #oldPkgs.qt5.qttools
        #oldPkgs.qt5.qtdeclarative
        #oldPkgs.qt5.qt5compat
        oldPkgs.qt5.qtwebchannel
        #oldPkgs.qt5.qtpositioning
      ];
      in
      pkgs.mkShell {
        inherit src;
        buildInputs = with oldPkgs; [
          qtEnv
          qt5.qtbase

          gnumake
          gcc
          gdb
          qtcreator

          # this is for the shellhook portion
          makeWrapper
          bashInteractive
        ] ++ buildTimeDeps;
        # set the environment variables that Qt apps expect
        shellHook = ''
          echo "Entering Qt5 development environment"

          # Set up Qt5 library paths for linking
          export QT_PLUGIN_PATH="${qtEnv}/lib/qt-5/plugins"
          export QML_IMPORT_PATH="${qtEnv}/lib/qt-5/qml"
          export QT_QPA_PLATFORM_PLUGIN_PATH="${qtEnv}/lib/qt-5/plugins/platforms"

          # Additional Qt5 library paths
          export PKG_CONFIG_PATH="${qtEnv}/lib/pkgconfig:$PKG_CONFIG_PATH"
          export QT_QPA_PLATFORM=wayland

          ${wabellib.devShells.commonSetup}
          makeWrapper "$(type -p bash)" "$TMPDIR/bash" "''${qtWrapperArgs[@]}"

          echo
          echo Type 'qtcreator .' to start developing!
          exec "$TMPDIR/bash"
        '';
      };
    };
  };
}
