with builtins;
let

  inherit (builtins) fetchTarBall fetchGit;


  # When trying to build using more recent versions of nixpkgs and ghc I ran into this issue:
  # https://github.com/ghcjs/jsaddle/issues/85
  # Seems like a rabbit hole I don't want to go down on right now, so
  # I'm pinning to the same versions used here:
  # https://github.com/dmjio/miso/blob/18de471f5ac16e67803a31f72a3028d87df2f0b7/jsaddle.nix

  pkgs = import (fetchTarball {
       url = "https://github.com/NixOS/nixpkgs/archive/a01a52a2d7e116e059d43d7803be313fb1a825ad.tar.gz";
       sha256 =  "0ps3cpaz46iffrb8xipzhdi64mpyhh2gfgp4bhbvg34lxv1q0xxi";
    }) {};


  compiler = "ghc843";

  inherit (pkgs.haskell.lib) dontCheck dontHaddock;

  jsaddlePkgs = super:
    let
         inherit (super) callPackage;
         jsaddleSrc = fetchGit {
             name = "jsaddle";
             url = "https://github.com/ghcjs/jsaddle.git";
             rev = "98a00b334b0ce62bf6bd3a4af682b25a8ea28193";
         };
     in
        {
              jsaddle = callPackage "${jsaddleSrc}/jsaddle" {};
              jsaddle-warp = dontCheck (callPackage "${jsaddleSrc}/jsaddle-warp" {});
              jsaddle-webkit2gtk = callPackage  "${jsaddleSrc}/jsaddle-webkit2gtk" {};
        };

 massivPkgs = super:
   let
      inherit (super) callCabal2nix callHackage;
      schedulerSrc = fetchGit {
         name = "scheduler";
         url = "https://github.com/lehins/haskell-scheduler";
         rev = "b503f1c76f8f6e9d69ad96807a19347ad6ee98fc";
      };
      massivSrc = fetchGit {
        name = "massiv";
        url = "https://github.com/lehins/massiv.git";
        rev = "3809bf8885f7de4d41fc1a2357888e5e1f0669b3";
      };
   in
    { fib = callHackage "fib" "0.1" {};
      scheduler = callCabal2nix "scheduler" "${schedulerSrc}/scheduler" {};
      massiv = callCabal2nix "massiv" "${massivSrc}/massiv" {};
      massiv-io = callCabal2nix "massiv-io" "${massivSrc}/massiv-io" {};
    };


  haskellPkgs = pkgs.haskell.packages.${compiler}.override(oldAttrs: {
     overrides = self: super: {
        miso =
          let
            misoSrc = fetchGit {
                name = "miso";
                url = "https://github.com/dmjio/miso.git";
                rev = "18de471f5ac16e67803a31f72a3028d87df2f0b7";
            };
          in
            super.callPackage  "${misoSrc}/miso-ghc-jsaddle.nix" {};
        haskell-gi-overloading = dontHaddock (self.callHackage "haskell-gi-overloading" "0.0" {});
     } // (jsaddlePkgs super) // (massivPkgs super);
  });


  glyphcollector = haskellPkgs.callCabal2nix "glyphcollector" ./. {};


in
  { app = glyphcollector;
    shell =
    let
        all-hies = import (fetchGit {
           name = "all-hies" ;
           url = "https://github.com/Infinisil/all-hies.git";
           rev = "81e51c7b1acfabab8b2b75c31ad684e20df6f67f";
        }) {};

        hie = all-hies.selection { selector = p: { "${compiler}" = p.${compiler}; }; };
    in
    # haskellPkgs.shellFor {
    #     packages = _: [glyphcollector];
    #     buildInputs = with pkgs; [cabal-install hie];
    #     withHoogle = true;
    # };
    glyphcollector.env.overrideAttrs (oldAttrs: {
       buildInputs = with pkgs; oldAttrs.buildInputs ++ [cabal-install hie] ;
       shellHook = ''
       ${oldAttrs.shellHook}
       set -o vi
       alias ghc='ghc -Werror'
       '';
    });
  }
