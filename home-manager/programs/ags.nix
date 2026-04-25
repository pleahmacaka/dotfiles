{ pkgs, ... }:

let
  astalGjs = pkgs.astal.gjs;

  extraGiTypelibs = builtins.concatStringsSep ":" [
    "${pkgs.astal.apps}/lib/girepository-1.0"
    "${pkgs.astal.astal4}/lib/girepository-1.0"
    "${pkgs.astal.io}/lib/girepository-1.0"
    "${pkgs.gtk4}/lib/girepository-1.0"
    "${pkgs.graphene}/lib/girepository-1.0"
  ];

  # Wrap ags so GTK4 typelibs are always available
  wrappedAgs = pkgs.symlinkJoin {
    name = "ags-wrapped";
    paths = [ pkgs.ags ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ags \
        --prefix GI_TYPELIB_PATH : "${extraGiTypelibs}"
    '';
  };
in
{
  home.packages = [
    wrappedAgs
    pkgs.astal.apps
    pkgs.astal.astal4
    pkgs.astal.io
    pkgs.astal.gjs
    pkgs.graphene
  ];

  home.file.".config/ags" = {
    source = ./ags;
    recursive = true;
  };

  home.file.".config/ags/tsconfig.json".text = builtins.toJSON {
    "$schema" = "https://json.schemastore.org/tsconfig";
    compilerOptions = {
      experimentalDecorators = true;
      strict = true;
      target = "ES2022";
      module = "ES2022";
      moduleResolution = "Bundler";
      jsx = "react-jsx";
      jsxImportSource = "astal/gtk4";
    };
  };

  home.file.".config/ags/env.d.ts".text = ''
    declare const SRC: string

    declare module "inline:*" {
        const content: string
        export default content
    }

    declare module "*.scss" {
        const content: string
        export default content
    }

    declare module "*.blp" {
        const content: string
        export default content
    }

    declare module "*.css" {
        const content: string
        export default content
    }
  '';

  home.file.".config/ags/node_modules/astal".source = "${astalGjs}/share/astal/gjs";
}
