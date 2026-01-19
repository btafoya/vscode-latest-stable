{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, lib, system, ... }: {
        imports = [ "${nixpkgs}/nixos/modules/misc/nixpkgs.nix" ];
        nixpkgs = {
          hostPlatform = system;
          config.allowUnfree = true;
        };
        formatter = pkgs.nixfmt;

        packages = rec {
          default = pkgs.vscode.overrideAttrs
            (oldAttrs: {
              src = (builtins.fetchTarball {
                url =
                  "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64";
                sha256 = "0mh6xanjmh42pi1jw7fg28r27zjivm784iazq2a5mmpdmh53d15k";
              });
              version = "latest";

              buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];

              # MSAL runtime has optional webkit/libsoup deps for native auth
              # VS Code falls back to browser-based auth when unavailable
              autoPatchelfIgnoreMissingDeps = [
                "libwebkit2gtk-4.1.so.0"
                "libsoup-3.0.so.0"
              ];

              meta.mainProgram = "code";
            });
          vscode-latest-stable = default;
        };
      };

    };
}
