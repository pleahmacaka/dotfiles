default:
    @just --list

format:
    nix run nixpkgs#nixfmt -- $(find . -name '*.nix' -not -path './.git/*' -not -name 'hardware-configuration.nix')

agenix:
    #!/usr/bin/env bash
    set -euo pipefail
    rules="secrets/secrets.nix"
    [[ -f "$rules" ]] || { echo "✗ $rules not found - run from the repo root."; exit 1; }

    set_key() {
      local var="$1" key
      key="$(tr -d '\n' <<<"$2" | sed 's/[[:space:]]*$//')"
      if grep -qE "^  ${var} = " "$rules"; then
        sed -i "s|^  ${var} = .*|  ${var} = \"${key}\";|" "$rules"
        echo "  ✓ ${var}"
      else
        echo "  ! no '${var}' field in $rules - skipped"
      fi
    }

    echo "== agenix auto-config =="

    opub="$HOME/.ssh/id_ed25519.pub"
    if [[ ! -f "$opub" ]]; then
      read -rp "No operator key (~/.ssh/id_ed25519). Generate one now? [y/N] " a
      [[ "$a" =~ ^[Yy]$ ]] && ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519"
    fi
    if [[ -f "$opub" ]]; then
      read -rp "Register operator key from $opub? [Y/n] " a
      [[ "$a" =~ ^[Nn]$ ]] || set_key operator "$(cat "$opub")"
    fi

    var="$(hostname)"; var="${var#nixos-}"
    hpub="/etc/ssh/ssh_host_ed25519_key.pub"
    if [[ -f "$hpub" ]]; then
      read -rp "Register THIS host ('$var') key from $hpub? [Y/n] " a
      [[ "$a" =~ ^[Nn]$ ]] || set_key "$var" "$(cat "$hpub")"
    fi

    read -rp "Fetch host keys from remote machines over SSH? [y/N] " a
    if [[ "$a" =~ ^[Yy]$ ]]; then
      while true; do
        read -rp "  rules var (e.g. desktop, pi-01) - blank to stop: " var
        [[ -z "$var" ]] && break
        read -rp "  ssh target for '$var' (e.g. root@cluster-pi-01): " tgt
        [[ -z "$tgt" ]] && continue
        if key="$(ssh "$tgt" cat /etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null)"; then
          set_key "$var" "$key"
        else
          echo "  ✗ could not reach $tgt"
        fi
      done
    fi

    shopt -s nullglob; ages=(secrets/*.age)
    if (( ${#ages[@]} )); then
      read -rp "Rekey ${#ages[@]} existing secret(s) now? [y/N] " a
      [[ "$a" =~ ^[Yy]$ ]] && ( cd secrets && agenix -r ) && echo "  ✓ rekeyed"
    fi

    echo; echo "== recipients now in $rules =="
    grep -nE '^  [a-z0-9-]+ = "ssh-' "$rules" || true
    echo; echo "Still unset:"; grep -n REPLACE_ME "$rules" || echo "  (none - all filled)"

deploy target='all':
    #!/usr/bin/env bash
    set -euo pipefail

    user="${DEPLOY_USER:-root}"
    auto="${YES:-}"
    sudo_flags=(); [[ "$user" == root ]] || sudo_flags=(--sudo --ask-sudo-password)

    sel="{{ target }}"
    mapfile -t all < <(nix eval --json '.#nixosConfigurations' \
      --apply 'c: builtins.filter (n: builtins.match "cluster-.*" n != null) (builtins.attrNames c)' \
      2>/dev/null | tr -d '[]" ' | tr ',' '\n' | sed '/^$/d')
    (( ${#all[@]} )) || { echo "✗ no cluster-* nodes in the flake."; exit 1; }

    if [[ "$sel" == all ]]; then
      targets=("${all[@]}")
    else
      [[ "$sel" == cluster-* ]] || sel="cluster-$sel"
      printf '%s\n' "${all[@]}" | grep -qx "$sel" || { echo "✗ unknown node '$sel'"; exit 1; }
      targets=("$sel")
    fi

    ssh_opts=(-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new)
    on() { ssh "${ssh_opts[@]}" "$user@$1" "${@:2}"; }

    echo "== preflight (nothing is touched until all of this passes) =="

    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
      echo "⚠ dirty working tree — untracked files are NOT seen by nix:"
      git status --short
      if git status --porcelain | grep -q '^??.*\.nix$'; then
        echo "  ✗ untracked .nix file(s) above will be ignored. git add them first."
        exit 1
      fi
      [[ -n "$auto" ]] || { read -rp "  continue anyway? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; }
    fi

    for t in "${targets[@]}"; do
      on "$t" true 2>/dev/null || { echo "✗ unreachable: $user@$t"; exit 1; }
      echo "  ✓ reachable   $t"
    done

    for t in "${targets[@]}"; do
      echo "  → building    $t"
      nix build --no-link ".#nixosConfigurations.${t}.config.system.build.toplevel" \
        || { echo "✗ build failed for $t — nothing deployed."; exit 1; }
    done

    probe="${targets[0]}"
    clustered=false
    if members="$(on "$probe" incus cluster list -c ns -f csv,noheader 2>/dev/null)" && [[ -n "$members" ]]; then
      clustered=true
      bad="$(awk -F, 'tolower($2) != "online"' <<<"$members" || true)"
      if [[ -n "$bad" ]]; then
        echo "✗ cluster members not online:"; sed 's/^/    /' <<<"$bad"; exit 1
      fi
      echo "  ✓ cluster     $(wc -l <<<"$members") members, all online"
    else
      echo "  · cluster     not formed yet — evacuation steps will be skipped"
    fi

    echo; echo "== deploying: ${targets[*]} =="

    for t in "${targets[@]}"; do
      echo; echo "-- $t ------------------------------------------------------"

      if [[ -z "$auto" && ${#targets[@]} -gt 1 ]]; then
        read -rp "deploy $t now? [Y/n/q] " a
        [[ "$a" =~ ^[Qq]$ ]] && { echo "stopped before $t."; exit 0; }
        [[ "$a" =~ ^[Nn]$ ]] && { echo "  skipped $t"; continue; }
      fi

      if $clustered; then
        echo "  → evacuating (containers migrate to the other members)"
        on "$t" incus cluster evacuate -f "$t"
      fi

      nixos-rebuild switch --flake ".#$t" --target-host "$user@$t" "${sudo_flags[@]}" || {
        echo "✗ switch failed on $t. The node is still on its previous generation."
        $clustered && echo "  it is EVACUATED — restore it with:  ssh $user@$t incus cluster restore $t"
        exit 1
      }

      booted="$(on "$t" 'readlink -f /run/booted-system/{initrd,kernel,kernel-modules}' 2>/dev/null || true)"
      current="$(on "$t" 'readlink -f /run/current-system/{initrd,kernel,kernel-modules}' 2>/dev/null || true)"
      if [[ -n "$booted" && "$booted" != "$current" ]]; then
        echo "  → kernel changed, rebooting"
        if [[ "$user" == root ]]; then
          on "$t" systemctl reboot || true
        else
          on "$t" 'sudo systemctl reboot' 2>/dev/null || ssh -t "$user@$t" sudo systemctl reboot || true
        fi
        sleep 10
        for i in $(seq 1 60); do
          on "$t" true 2>/dev/null && break
          [[ $i == 60 ]] && { echo "✗ $t did not come back in 10min — DID NOT restore it."; exit 1; }
          sleep 10
        done
        echo "  ✓ back up"
      else
        echo "  · no kernel change, no reboot needed"
      fi

      if $clustered; then
        echo "  → restoring to the cluster"
        on "$t" incus cluster restore -f "$t"
        for i in $(seq 1 30); do
          st="$(on "$t" incus cluster list -c ns -f csv,noheader 2>/dev/null | awk -F, -v n="$t" '$1==n{print tolower($2)}')"
          [[ "$st" == online ]] && break
          [[ $i == 30 ]] && { echo "✗ $t never returned to ONLINE — stopping before the next node."; exit 1; }
          sleep 5
        done
      fi
      echo "  ✓ $t done"
    done

    echo; echo "✓ all done: ${targets[*]}"

image:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "== cluster bootstrap-image builder =="

    mapfile -t nodes < <(nix eval --json '.#packages.aarch64-linux' \
      --apply 'p: builtins.filter (n: builtins.match "image-.*" n != null) (builtins.attrNames p)' \
      2>/dev/null | tr -d '[]" ' | tr ',' '\n' | sed '/^$/d')
    (( ${#nodes[@]} )) || { echo "✗ no image-* packages in the flake."; exit 1; }

    echo "Images: ${nodes[*]}"
    read -rp "Which node? (e.g. image-pi-01, pi-01, or 'all') [all]: " sel
    sel="${sel:-all}"
    if [[ "$sel" == all ]]; then
      targets=("${nodes[@]}")
    else
      [[ "$sel" == image-* ]] || sel="image-${sel#cluster-}"
      printf '%s\n' "${nodes[@]}" | grep -qx "$sel" || { echo "✗ unknown image '$sel'"; exit 1; }
      targets=("$sel")
    fi

    emulated=false
    [[ "$(uname -m)" == aarch64 ]] && emulated=true
    [[ -e /run/binfmt/aarch64-linux ]] && emulated=true
    { nix show-config 2>/dev/null || nix config show 2>/dev/null; } | grep -E '^extra-platforms' | grep -q aarch64 && emulated=true
    if ! $emulated; then
      echo "⚠ no aarch64 builder detected on this host."
      echo "  enable emulation:  boot.binfmt.emulatedSystems = [ \"aarch64-linux\" ];  (then switch)"
      echo "  or use a remote aarch64 builder."
      read -rp "Try anyway (fails without a builder)? [y/N] " a
      [[ "$a" =~ ^[Yy]$ ]] || exit 1
    fi

    imgs=()
    for t in "${targets[@]}"; do
      out="result-${t#image-}"
      echo "→ building $t -> $out ..."
      nix build ".#packages.aarch64-linux.${t}" -o "$out"
      img="$(find -L "$out" -name '*.img*' 2>/dev/null | head -1)"
      [[ -n "$img" ]] || { echo "✗ $out holds no *.img* — refusing to print a flash command."; exit 1; }
      imgs+=("$img")
      echo "  ✓ $img"
    done

    echo
    echo "Optional headless tailnet join: drop a pre-auth key on the FIRMWARE partition"
    echo "  after flashing:  echo tskey-auth-... > /run/media/\$USER/FIRMWARE/ts-authkey"
    echo "Flash (lsblk first — of= is the whole disk, not a partition):"
    for img in "${imgs[@]}"; do
      echo "  zstdcat $img | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync"
    done
