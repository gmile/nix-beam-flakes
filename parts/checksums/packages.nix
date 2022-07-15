{...}: {
  perSystem = {
    config,
    lib,
    pkgs,
    ...
  }: {
    apps = {
      add-elixir-version.program =
        lib.getExe config.packages.add-elixir-version;
      add-otp-version.program = lib.getExe config.packages.add-otp-version;
    };

    packages = let
      jqPushChecksum = name: target: prefetcher:
        pkgs.writeShellScriptBin name ''
          set -ex -o pipefail
          version=$1
          targetFile=${target}
          checksum=$(${lib.getExe prefetcher} $version)
          editCommand=".[\"$version\"] = \"$checksum\""
          ${pkgs.jq}/bin/jq --sort-keys "$editCommand" $targetFile | ${pkgs.moreutils}/bin/sponge $targetFile
        '';
      listGitHubReleases = name: repo:
        pkgs.writeShellScriptBin name ''
          ${pkgs.gh}/bin/gh release list -R ${repo}
        '';
    in {
      add-elixir-version =
        jqPushChecksum "add-elixir-version" "$PWD/data/elixir.json"
        config.packages.nix-prefetch-elixir;

      add-otp-version =
        jqPushChecksum "add-otp-version" "$PWD/data/erlang.json"
        config.packages.nix-prefetch-otp;

      list-all-elixir = listGitHubReleases "list-all-otp" "elixir-lang/elixir";
      list-all-otp = listGitHubReleases "list-all-otp" "erlang/otp";
    };
  };
}