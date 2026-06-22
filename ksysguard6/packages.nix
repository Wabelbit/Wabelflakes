{
  self,
  inputs,
  ...
}: {
  perSystem = {pkgs, lib, ...}@args: let
    wabellib = import ../lib.nix args;
    src = inputs.ksysguard6;
    pname = "ksysguard6";
    version = "6.0.1";
    rev = "1b76da82ec259c18ffb4ec94af2ce6dd715c4ac5";
    shortrev = builtins.substring 0 7 rev;
    fullVersion = "${version}+git-${shortrev}";
    buildTimeDeps = with pkgs; [
      cmake
      ninja
      pkg-config
      python315
      qt6.wrapQtAppsHook
      kdePackages.extra-cmake-modules
      #kdePackages.qtbase
      #kdePackages.qtdeclarative
      #kdePackages.frameworkintegration
      kdePackages.knotifications
      kdePackages.kwindowsystem
      kdePackages.kconfigwidgets
      kdePackages.kglobalaccel
      kdePackages.kxmlgui
      kdePackages.knewstuff
      kdePackages.kdbusaddons
      kdePackages.kdoctools
      kdePackages.kio
      kdePackages.kauth
      kdePackages.libksysguard
      kdePackages.qtwebengine
      kdePackages.qtwebchannel
      libpcap
      libnl
      lm_sensors
      #moveOutputsHook
      #qmllintHook
    ];
  in {
    packages = {
      ksysguard6 = pkgs.stdenv.mkDerivation {
        inherit pname src;
        version = fullVersion;

        buildInputs = [ pkgs.qt6.qtbase ];
        nativeBuildInputs = buildTimeDeps;

        cmakeFlags = [ "-DQT_MAJOR_VERSION=6" ];
        doInstallCheck = true;
        separateDebugInfo = true;

        meta = {
          homepage = "https://github.com/zvova7890/ksysguard6/tree/master";
          description = "The beloved classic KSysGuard, brought to KDE 6";
          license = lib.licenses.gpl2;
        };
      };
    };
    devShells = {
      ksysguard6 = let
        qtEnv = pkgs.qt6.env "qt6-simc-${pkgs.qt6.qtbase.version}" [
        pkgs.qt6.qtbase
        pkgs.qt6.qtwebengine
        #pkgs.qt6.qttools
        #pkgs.qt6.qtdeclarative
        #pkgs.qt6.qt5compat
        pkgs.qt6.qtwebchannel
        #pkgs.qt6.qtpositioning
      ];
      in
      pkgs.mkShell {
        inherit src;
        buildInputs = with pkgs; [
          qtEnv
          qt6.qtbase

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
          echo "Entering Qt6 development environment"

          # Set up Qt6 library paths for linking
          export QT_PLUGIN_PATH="${qtEnv}/lib/qt-6/plugins"
          export QML_IMPORT_PATH="${qtEnv}/lib/qt-6/qml"
          export QT_QPA_PLATFORM_PLUGIN_PATH="${qtEnv}/lib/qt-6/plugins/platforms"

          # Additional Qt6 library paths
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
