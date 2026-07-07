{ lib, ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      (lib.genAttrs [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
        "x-scheme-handler/chrome"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/xhtml+xml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
      ] (_: "brave-browser.desktop"))
      // (lib.genAttrs [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/x-flv"
        "video/mpeg"
        "video/x-ms-wmv"
        "video/ogg"
        "video/3gpp"
        "application/x-matroska"
      ] (_: "vlc.desktop"));
  };
}
