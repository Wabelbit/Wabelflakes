{ pkgs, ... }:
{
  devShells.commonSetup = ''
    [ -v src ] || { echo 'ERROR: $src is not set, refusing to proceed!'; exit 1; }
    echo "Read-only project source is in: $src"
    TMPDIR=`${pkgs.coreutils}/bin/mktemp -d`
    echo "Copying to $TMPDIR..."
    cp -r "$src/"* "$TMPDIR/" || true
    cp -r "$src/".* "$TMPDIR/" || true
    echo "Adjusting permissions..."
    ${pkgs.coreutils}/bin/chmod ug+w -R $TMPDIR
    cd "$TMPDIR"
  '';
}
