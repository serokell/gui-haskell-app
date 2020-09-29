let
  nixpkgsPin = {
    url = https://github.com/nixos/nixpkgs/archive/5659cb448e9b615d642c5fe52779c2223e72f7eb.tar.gz;
    sha256 = "1ijwr9jlvdnvr1qqpfdm61nwd871sj4dam28pcv0pvnmp8ndylak";
  };
  pkgs = import (builtins.fetchTarball nixpkgsPin) {};
in

pkgs.stdenv.mkDerivation rec {
  name = "gui-haskell-app";
  src = ./.;
  buildInputs = [
    (pkgs.haskell.packages.ghc865.ghcWithPackages (p: [
      p.gi-gtk
    ]))
    pkgs.cabal-install
    pkgs.pkgconfig
    pkgs.gtk3
    pkgs.gobject-introspection
  ];
  libPath = pkgs.lib.makeLibraryPath buildInputs;
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:$LD_LIBRARY_PATH
    export LANG=en_US.UTF-8
  '';
  LOCALE_ARCHIVE =
    if pkgs.stdenv.isLinux
    then "${pkgs.glibcLocales}/lib/locale/locale-archive"
    else "";
}
