let
  inherit (builtins) fetchTarball fetchGit;


  # When trying to build using more recent versions of nixpkgs and ghc I ran into this issue:
  # https://github.com/ghcjs/jsaddle/issues/85
  # Seems like a rabbit hole I don't want to go down on right now, so
  # I'm pinning to the same versions used here:
  # https://github.com/dmjio/miso/blob/18de471f5ac16e67803a31f72a3028d87df2f0b7/jsaddle.nix

  compiler = "ghc864";
  overlays = [ (import ./overlays.nix { inherit compiler; }) ];
  # normally I'd use fetchGit, but got "not a tree object for this revision"
  pkgs = import (fetchTarball {
       name = "nixpkgs" ;
       url = https://github.com/nixos/nixpkgs/archive/f52505fac8c82716872a616c501ad9eff188f97f.tar.gz; # 19.03 release from 2019-04-11
       sha256 = "0q2m2qhyga9yq29yz90ywgjbn9hdahs7i8wwlq7b55rdbyiwa5dy";
  }) {
      overlays = overlays;
    };

  inherit (pkgs) haskellPackages;
  app = haskellPackages.glyphcollector;
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
    haskellPackages.shellFor {
      packages = p: [app];
      buildInputs = with pkgs; [cabal-install hie ghcid] ;
      withHoogle = true;
    };
    # app.env.overrideAttrs (oldAttrs: {
    #    buildInputs = with pkgs; oldAttrs.buildInputs ++ [cabal-install hie ghcid] ;
    #    shellHook = ''
    #    ${oldAttrs.shellHook}
    #    set -o vi
    #    alias dev='ghcid -W --run'
    #    '';
    # });
}
