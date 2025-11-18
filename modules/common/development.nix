{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Python
    python313
    python313Packages.torch
    uv
  ];
}
