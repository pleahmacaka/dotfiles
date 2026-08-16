{
  lib,
  config,
  pkgs,
  ...
}:

{
  networking.firewall.allowedTCPPorts = [ 22 ];

  systemd.services.bootstrap-wifi = {
    description = "One-time Wi-Fi association from /boot/firmware/wifi.conf";
    wantedBy = [ "multi-user.target" ];
    before = [ "network-online.target" ];
    wants = [ "rfkill-unblock-wlan.service" ];
    after = [ "rfkill-unblock-wlan.service" ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };
    path = [
      pkgs.wpa_supplicant
      pkgs.iw
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    script = ''
      src=/boot/firmware/wifi.conf
      if [ ! -f "$src" ]; then
        echo "no $src — skipping Wi-Fi (use ethernet)"
        exit 0
      fi

      iface=""
      for d in /sys/class/net/*; do
        [ -e "$d/wireless" ] && { iface="$(basename "$d")"; break; }
      done
      [ -n "$iface" ] || { echo "no wireless interface found"; exit 1; }

      conf=/run/bootstrap-wpa_supplicant.conf
      install -m600 /dev/null "$conf"
      if grep -q 'network=' "$src"; then
        cat "$src" >"$conf"
      else
        ssid="$(sed -n 's/^[[:space:]]*ssid=//p' "$src" | head -1 | tr -d '\r')"
        psk="$(sed -n 's/^[[:space:]]*psk=//p' "$src" | head -1 | tr -d '\r')"
        [ -n "$ssid" ] || { echo "$src has no ssid="; exit 1; }
        if [ -n "$psk" ]; then
          wpa_passphrase "$ssid" "$psk" >"$conf"
        else
          printf 'network={\n  ssid="%s"\n  key_mgmt=NONE\n}\n' "$ssid" >"$conf"
        fi
      fi

      echo "associating $iface with the configured network"
      exec wpa_supplicant -i "$iface" -c "$conf"
    '';
  };

  systemd.services.bootstrap-tailscale = {
    description = "One-time Tailscale auto-join from /boot/firmware/ts-authkey";
    after = [
      "tailscaled.service"
      "network-online.target"
    ];
    wants = [
      "tailscaled.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.tailscale
    ];
    script = ''
      key=/boot/firmware/ts-authkey
      if [ ! -f "$key" ]; then
        echo "no $key — skipping tailnet auto-join (reach me over the LAN instead)"
        exit 0
      fi

      for i in $(seq 1 60); do
        [ "$(timedatectl show -p NTPSynchronized --value)" = yes ] && break
        [ "$i" = 60 ] && echo "clock still unsynchronised after 5min, trying anyway"
        sleep 5
      done

      for i in $(seq 1 30); do
        if tailscale up --ssh \
             --auth-key="$(cat "$key")" \
             --hostname="${config.networking.hostName}"; then
          shred -u "$key" 2>/dev/null || rm -f "$key"
          exit 0
        fi
        echo "tailnet join attempt $i failed, retrying in 10s"
        sleep 10
      done

      echo "tailnet join never succeeded — do NOT deploy this node yet"
      exit 1
    '';
  };

  systemd.services.bootstrap-publish-hostkey = {
    description = "Publish SSH host public key for agenix enrollment";
    after = [ "sshd.service" ];
    wants = [ "sshd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      pub=/etc/ssh/ssh_host_ed25519_key.pub
      [ -f "$pub" ] || exit 0
      dst="/boot/firmware/${config.networking.hostName}.hostkey.pub"
      ${pkgs.coreutils}/bin/install -m444 "$pub" "$dst" || true
      echo "================ BOOTSTRAP: host identity ================"
      echo "host: ${config.networking.hostName}"
      echo "register this recipient in secrets/secrets.nix:"
      ${pkgs.coreutils}/bin/cat "$pub"
      echo "also written to: $dst"
      echo "========================================================="
    '';
  };

}
