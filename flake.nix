{
  description = "SkillHub development environment for Flutter + SQLite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # use your preferred channel
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.flutter
          pkgs.sqlite
          pkgs.gcc
          pkgs.pkg-config
          pkgs.glibc
        ];

        # Environment for sqflite_common_ffi
        shellHook = ''
          echo "========================================"
          echo " SkillHub Nix Dev Environment"
          echo " Flutter + SQLite + sqflite_ffi"
          echo "========================================"

          export SQLITE3_LIB_DIR=${pkgs.sqlite.out}/lib
          export LD_LIBRARY_PATH="$SQLITE3_LIB_DIR:$LD_LIBRARY_PATH"
          export DYLD_LIBRARY_PATH="$SQLITE3_LIB_DIR:$DYLD_LIBRARY_PATH"

          echo "SQLite dynamic library path:"
          echo "  $SQLITE3_LIB_DIR"
          echo ""
          echo "To run unit tests:"
          echo "  flutter test test/database_helper_test.dart"
          echo ""
        '';
      };
    };
}
