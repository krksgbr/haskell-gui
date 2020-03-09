
## Unfortunately OpenCV doesn't build.
## Fundamentally the problem is that Jsaddle only builds on an older pin of nixpkgs,
## while OpenCV will only build on a more recent one.
## 1. Try finding a middle ground.
##     nixpkgs/ghc versions where both build
## 2. Try upgrading nixpkgs and ghc to latest and whatever error comes up
##    OpenCV does build that way
## 3. Make own bindings to OpenCV

with builtins;
let

  inherit (builtins) fetchTarBall fetchGit;


  # When trying to build using more recent versions of nixpkgs and ghc I ran into this issue:
  # https://github.com/ghcjs/jsaddle/issues/85
  # Seems like a rabbit whole I don't want to go down on right now, so
  # I'm pinning to the same versions used here:
  # https://github.com/dmjio/miso/blob/18de471f5ac16e67803a31f72a3028d87df2f0b7/jsaddle.nix

  # pkgs = import (fetchTarball {
  #      url = "https://github.com/NixOS/nixpkgs/archive/a01a52a2d7e116e059d43d7803be313fb1a825ad.tar.gz";
  #      sha256 =  "0ps3cpaz46iffrb8xipzhdi64mpyhh2gfgp4bhbvg34lxv1q0xxi";
  #   }) {};


  pkgs = import (fetchGit {
       name = "nixpkgs-pinned-2019-05-29";
       url =  "https://github.com/NixOS/nixpkgs.git";
       rev = "60b59c34a868f5e835e8af187b961ed328dd23e9";
    }) {};

  compiler = "ghc864";

  inherit (pkgs.haskell.lib) dontCheck dontHaddock;



  opencvSrc = fetchGit {
    name = "haskell-opencv";
    url = "https://github.com/LumiGuide/haskell-opencv.git";
    rev = "0d0c1cbe2dd8e7705f6785c8bd4645cd18faebfb";
  };

  haskellPkgs = pkgs.haskell.packages.${compiler}.override(oldAttrs: {
     # overrides = self: super: {
     #    miso =
     #      let
     #        misoSrc = fetchGit {
     #            name = "miso";
     #            url = "https://github.com/dmjio/miso.git";
     #            rev = "18de471f5ac16e67803a31f72a3028d87df2f0b7";
     #        };
     #      in
     #        super.callPackage  "${misoSrc}/miso-ghc-jsaddle.nix" {};
     #    haskell-gi-overloading = dontHaddock (self.callHackage "haskell-gi-overloading" "0.0" {});
     #    # opencv = super.callPackage "${opencvSrc}/opencv" {};
     # } //
     # (let
     #     jsaddleSrc = fetchGit {
     #         name = "jsaddle";
     #         url = "https://github.com/ghcjs/jsaddle.git";
     #         rev = "98a00b334b0ce62bf6bd3a4af682b25a8ea28193";
     #     };
     # in
     #    {
     #          jsaddle = super.callPackage "${jsaddleSrc}/jsaddle" {};
     #          jsaddle-warp = dontCheck (super.callPackage "${jsaddleSrc}/jsaddle-warp" {});
     #          jsaddle-webkit2gtk = super.callPackage  "${jsaddleSrc}/jsaddle-webkit2gtk" {};
     #    }
     # );
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
