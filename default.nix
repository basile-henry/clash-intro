{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:
with import nixpkgs { inherit system; };

let
  revealjs = fetchFromGitHub {
    owner = "hakimel";
    repo  = "reveal.js";
    rev = "65bdccd5807b6dfecad6eb3ea38872436d291e81";
    sha256 ="07460ij4v7l2j0agqd2dsg28gv18bf320rikcbj4pb54k5pr1218";
  };
in
  stdenv.mkDerivation rec {
    name = "clash-intro";
    src = ./src;
    buildInputs = [
      pandoc
      revealjs
    ];
    buildPhase = ''
      pandoc -t revealjs \
        --standalone \
        --slide-level=2 \
        -V theme=serif \
        --output ./${name}.html \
        ${name}.md
    '';
    installPhase = ''
      mkdir -p $out
      cp * $out/
      cp -r ${revealjs} $out/reveal.js
    '';
  }
