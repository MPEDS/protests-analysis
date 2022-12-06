{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils } :
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShell = (pkgs.buildFHSUserEnv {
					name = "renv-compatible nix";
          targetPkgs = pkgs:
            (with pkgs; [
              binutils
              curl.dev
              gcc
              libgit2
							gdal
							proj
              libxml2.dev
              openssl.dev
              pandoc
							zlib
              pkg-config
              R
              rPackages.renv
            ]);
					runScript = "bash";
        }).env;
      });
}
