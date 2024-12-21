{
  description = "a justfile that takes a Pandoc-flavored markdown file and
  renders it as a resume in various formats";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    utils-pandoc.url  = "github:friedenberg/dev-flake-templates?dir=pandoc";
    chromium-html-to-pdf.url = "github:friedenberg/chromium-html-to-pdf";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, utils, utils-pandoc, chromium-html-to-pdf }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "markdown-to-resume";
        buildInputs = with pkgs; [ pandoc just chromium-html-to-pdf ];
        markdown-to-resume = (
          pkgs.writeScriptBin name (builtins.readFile ./justfile)
        ).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        # to include all the templates and styles
        src = ./.;

      in rec {
        defaultPackage = packages.markdown-to-resume;
        packages.markdown-to-resume = pkgs.symlinkJoin {
          name = name;
          paths = [ markdown-to-resume src ] ++ buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        devShells.default = pkgs.mkShell {
          packages = (with pkgs; [
            pandoc
            just
            chromium-html-to-pdf.packages.${system}.html-to-pdf
            markdown-to-resume
          ]);

          inputsFrom = [];
        };
      }
    );
}
