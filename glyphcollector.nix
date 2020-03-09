let
  inherit (builtins) fetchTarBall fetchGit;


  # When trying to build using more recent versions of nixpkgs and ghc I ran into this issue:
  # https://github.com/ghcjs/jsaddle/issues/85
  # Seems like a rabbit hole I don't want to go down on right now, so
  # I'm pinning to the same versions used here:
  # https://github.com/dmjio/miso/blob/18de471f5ac16e67803a31f72a3028d87df2f0b7/jsaddle.nix

  overlays = [(import ./overlays.nix)];
  pkgs = import (fetchTarball {
       url = "https://github.com/NixOS/nixpkgs/archive/a01a52a2d7e116e059d43d7803be313fb1a825ad.tar.gz";
       sha256 =  "0ps3cpaz46iffrb8xipzhdi64mpyhh2gfgp4bhbvg34lxv1q0xxi";
    }) {
      inherit overlays;
    };


  compiler = "ghc843";
  app = pkgs.haskellPackages.glyphcollector;
in
{   inherit app;
    shell =
    let
        all-hies = import (fetchGit {
           name = "all-hies" ;
           url = "https://github.com/Infinisil/all-hies.git";
           rev = "81e51c7b1acfabab8b2b75c31ad684e20df6f67f";
        }) {};

        hie = all-hies.selection { selector = p: { "${compiler}" = p.${compiler}; }; };

       ghcid = pkgs.haskellPackages.callCabal2nix "ghcid" (fetchGit {
          name = "ghcid";
          url = "https://github.com/ndmitchell/ghcid.git";
          rev = "939b009fb9426501cf3aa546f1573d4ebfe6645d";
       }){};
    in
    app.env.overrideAttrs (oldAttrs: {
       buildInputs = with pkgs; oldAttrs.buildInputs ++ [cabal-install hie ghcid] ;
       shellHook = ''
       ${oldAttrs.shellHook}
       set -o vi
       alias dev='ghcid -W --run'
       '';
    });
}
