self: super:
let
  inherit (self.haskell.lib) dontCheck dontHaddock;
  inherit (builtins) fetchTarBall fetchGit;

in
{
  haskellPackages = super.haskell.packages.ghc843.override  {
    overrides = hself: hsuper:
    let
      inherit (hself) callPackage callCabal2nix callHackage;

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

      misoSrc = fetchGit {
          name = "miso";
          url = "https://github.com/dmjio/miso.git";
          rev = "18de471f5ac16e67803a31f72a3028d87df2f0b7";
      };

      jsaddleSrc = ./jsaddle;
    in
    {
      fib = callHackage "fib" "0.1" {};
      scheduler = callCabal2nix "scheduler" "${schedulerSrc}/scheduler" {};
      massiv = callCabal2nix "massiv" "${massivSrc}/massiv" {};
      massiv-io = callCabal2nix "massiv-io" "${massivSrc}/massiv-io" {};
      haskell-gi-overloading = dontHaddock (callHackage "haskell-gi-overloading" "0.0" {});
      miso = callPackage  "${misoSrc}/miso-ghc-jsaddle.nix" {};
      jsaddle = callPackage "${jsaddleSrc}/jsaddle" {};
      jsaddle-warp = dontCheck (callPackage "${jsaddleSrc}/jsaddle-warp" {});
      jsaddle-webkit2gtk = callPackage  "${jsaddleSrc}/jsaddle-webkit2gtk" {};
      glyphcollector = callCabal2nix "glyphcollector" ./. {};
    };
  };
}
