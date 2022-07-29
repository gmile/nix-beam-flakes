{lib}: let
  inherit (findBasePackage) elixirBasePackage otpBasePackage;
  findBasePackage = import ./findBasePackage.nix {inherit lib;};

  mkElixir = beamPkgs: version: sha256: let
    basePkg = elixirBasePackage beamPkgs version;
  in
    basePkg.override {inherit sha256 version;};

  mkErlang = pkgs: version: sha256: let
    basePkg = otpBasePackage pkgs version;
  in
    basePkg.override {inherit sha256 version;};
in {
}