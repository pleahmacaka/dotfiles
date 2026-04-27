{ pkgs, ... }:

{
  home.packages = [ pkgs.libnotify ];

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "overlay";
      default-timeout = 5000;
      max-visible = 5;

      font = "sans 11";
      background-color = "#1e1e28e6";
      text-color = "#ffffff";
      border-color = "#a78bfa";
      progress-color = "over #7c3aed55";

      border-size = 1;
      border-radius = 12;
      padding = "12,16";
      margin = "10";
      icon-border-radius = 8;
      max-icon-size = 40;

      "urgency=low" = {
        border-color = "#5b5bd6";
      };
      "urgency=critical" = {
        border-color = "#ef4444";
        default-timeout = 0;
      };
    };
  };
}
