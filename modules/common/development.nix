{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313
    python313Packages.torch
    uv
  ];
}
