{compiler}: self: super:
let
  inherit (self.haskell.lib) dontCheck dontHaddock;
  inherit (builtins) fetchTarBall fetchGit;

in
{
  haskellPackages = super.haskell.packages.${compiler}.override  {
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

      webviewhsSrc = fetchGit {
         name = "webviewhs";
         url = "https://github.com/lettier/webviewhs.git";
         rev = "21f8ac8ff54369ebce1f7600dc71be6ee84ea099";
      };
      claySrc = fetchGit {
        name = "clay";
        url = "https://github.com/sebastiaanvisser/clay.git";
        rev = "54dc9eaf0abd180ef9e35d97313062d99a02ee75";
      };
      parseArgsSrc = fetchGit {
        name = "parseargs" ;
        url = "https://github.com/BartMassey/parseargs.git";
        rev = "be1acab1da4f358d4b96f4b6e0aa8691f0c399ce";
     };
    in
    {
      parseargs = dontCheck (callCabal2nix "parseArgs" parseArgsSrc {});
      fib = callHackage "fib" "0.1" {};
      scheduler = callCabal2nix "scheduler" "${schedulerSrc}/scheduler" {};
      massiv = callCabal2nix "massiv" "${massivSrc}/massiv" {};
      massiv-io = callCabal2nix "massiv-io" "${massivSrc}/massiv-io" {};
      clay = (callCabal2nix "clay" claySrc {}).overrideAttrs(oldAttrs : {
         patchPhase = ''
         substituteInPlace clay.cabal --replace "hspec                >= 2.2.0 && < 2.6," "hspec                >= 2.2.0 && < 2.7,"
         substituteInPlace clay.cabal --replace "hspec-discover       >= 2.2.0 && < 2.6" "hspec-discover       >= 2.2.0 && < 2.7"
         '';
      });
      jmacro = callHackage "jmacro" "0.6.16" {};
      webviewhs = callCabal2nix "webviewhs" webviewhsSrc {};
      glyphcollector = callCabal2nix "glyphcollector" ./. {};
    };
  };
}
