{
  description = "Gemini MCP Server - Google's Gemini AI via Model Context Protocol";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        python = pkgs.python312;

        pythonEnv = python.withPackages (ps: [
          ps.google-generativeai
          ps.httpx
          ps.mcp
        ]);

      in {
        packages.default = pkgs.writeShellScriptBin "gemini-mcp" ''
          exec ${pythonEnv}/bin/python ${./server.py} "$@"
        '';

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.python312Packages.pip
            pkgs.google-cloud-sdk
          ];

          shellHook = ''
            echo "Gemini MCP Server Development Environment"
            echo ""
            if [ -z "$GEMINI_API_KEY" ]; then
              echo "WARNING: GEMINI_API_KEY not set"
              echo "Set it with: export GEMINI_API_KEY='your-key'"
            else
              echo "GEMINI_API_KEY is set"
            fi
            echo ""
            echo "Run server: python server.py"
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/gemini-mcp";
        };
      }
    );
}
