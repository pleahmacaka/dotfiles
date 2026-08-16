{ ... }:

{
  nixpkgs.overlays = [
    (final: _prev: {
      qemu_kvm = final.runCommand "qemu-kvm-stub" { } ''
        mkdir -p $out/bin $out/libexec
      '';

      spice-gtk = final.runCommand "spice-gtk-stub" { } ''
        mkdir -p $out/bin
      '';

      lego = final.runCommand "lego-stub" { } ''
        mkdir -p $out/bin
      '';

      inherit
        (
          let
            fd = final.runCommand "ovmf-stub" { } ''
              mkdir -p $out/FV
              for f in AAVMF_CODE AAVMF_VARS OVMF_CODE OVMF_VARS; do : > "$out/FV/$f.fd"; done
            '';
            stub = fd // {
              inherit fd;
              override = _: stub;
              overrideAttrs = _: stub;
            };
          in
          {
            OVMF = stub;
            OVMFFull = stub;
          }
        )
        OVMF
        OVMFFull
        ;
    })
  ];
}
