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
							/* Needed for various R dependencies */
							libssh
							libpng
							gdal
							geos
							freetype.dev
							proj.dev
              libxml2.dev
              openssl.dev
							sqlite.dev
              pandoc
							zlib.dev
							unixODBC
							libmysqlclient.dev
							udunits
              pkg-config
							/* Needed for basic R setup */ 
              R
              rPackages.renv
            ]);
					runScript = "bash";
        }).env;
      });
}
