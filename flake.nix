{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils } :
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs {
        inherit system; 
        overlays = [(self: super: {
          customRstudio = super.rstudioWrapper.override {
            packages = [super.rPackages.renv];
          };
        })
      ];};
      in {
        devShells.default = (pkgs.buildFHSUserEnv {
          name = "renv-compatible nix";
            targetPkgs = pkgs:
            (with pkgs; [
              binutils
              curl.dev
              gcc
              libgit2
              /* Needed for various R dependencies */
              libssh
              libpng.dev
              libtiff.dev
              libjpeg.dev
              gdal
              geos
              fontconfig.dev
              freetype.dev
              harfbuzz.dev
              fribidi
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
              customRstudio
              ]);
              runScript = "bash";
              profile = ''
                export R_PROFILE=${builtins.toString ./.}/.Rprofile
                '';
          }).env;
    });
}
