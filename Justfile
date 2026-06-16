# `just` to list recipes, `just <name>` to run one.
default:
    @just --list

# Configure agenix recipients in secrets/secrets.nix interactively.
agenix:
    #!/usr/bin/env bash
    set -euo pipefail
    rules="secrets/secrets.nix"
    [[ -f "$rules" ]] || { echo "✗ $rules not found - run from the repo root."; exit 1; }

    # Write a `name = "<pubkey>";` recipient line in the rules file.
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

    # 1) Operator key (the human who edits secrets).
    opub="$HOME/.ssh/id_ed25519.pub"
    if [[ ! -f "$opub" ]]; then
      read -rp "No operator key (~/.ssh/id_ed25519). Generate one now? [y/N] " a
      [[ "$a" =~ ^[Yy]$ ]] && ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519"
    fi
    if [[ -f "$opub" ]]; then
      read -rp "Register operator key from $opub? [Y/n] " a
      [[ "$a" =~ ^[Nn]$ ]] || set_key operator "$(cat "$opub")"
    fi

    # 2) This host's key -> the matching rules var (nixos-laptop -> laptop, ...).
    var="$(hostname)"; var="${var#nixos-}"
    hpub="/etc/ssh/ssh_host_ed25519_key.pub"
    if [[ -f "$hpub" ]]; then
      read -rp "Register THIS host ('$var') key from $hpub? [Y/n] " a
      [[ "$a" =~ ^[Nn]$ ]] || set_key "$var" "$(cat "$hpub")"
    fi

    # 3) Remote hosts over SSH (loop until blank).
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

    # 4) Rekey existing secrets to the new recipient set.
    shopt -s nullglob; ages=(secrets/*.age)
    if (( ${#ages[@]} )); then
      read -rp "Rekey ${#ages[@]} existing secret(s) now? [y/N] " a
      [[ "$a" =~ ^[Yy]$ ]] && ( cd secrets && agenix -r ) && echo "  ✓ rekeyed"
    fi

    echo; echo "== recipients now in $rules =="
    grep -nE '^  [a-z0-9-]+ = "ssh-' "$rules" || true
    echo; echo "Still unset:"; grep -n REPLACE_ME "$rules" || echo "  (none - all filled)"

# Build a cluster node's SD-card image interactively.
image:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "== cluster image builder =="

    # Discover cluster-* nodes from the flake.
    mapfile -t nodes < <(nix eval --json '.#nixosConfigurations' \
      --apply 'c: builtins.filter (n: builtins.match "cluster-.*" n != null) (builtins.attrNames c)' \
      2>/dev/null | tr -d '[]" ' | tr ',' '\n' | sed '/^$/d')
    (( ${#nodes[@]} )) || { echo "✗ no cluster-* nodes in the flake."; exit 1; }

    echo "Nodes: ${nodes[*]}"
    read -rp "Which node? (name or short form, or 'all') [all]: " sel
    sel="${sel:-all}"
    if [[ "$sel" == all ]]; then
      targets=("${nodes[@]}")
    else
      [[ "$sel" == cluster-* ]] || sel="cluster-$sel"
      printf '%s\n' "${nodes[@]}" | grep -qx "$sel" || { echo "✗ unknown node '$sel'"; exit 1; }
      targets=("$sel")
    fi

    read -rp "Image format? [sd-card]: " fmt; fmt="${fmt:-sd-card}"

    # aarch64 build feasibility (the Pi images are aarch64-linux).
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

    for t in "${targets[@]}"; do
      out="result-${t#cluster-}"
      echo "→ building '$fmt' image for $t -> $out ..."
      nix build ".#nixosConfigurations.${t}.config.system.build.images.${fmt}" -o "$out"
      img="$(find -L "$out" -name '*.img*' 2>/dev/null | head -1)"; img="${img:-$out}"
      echo "  ✓ $img"
    done

    echo; echo "Flash:  zstdcat result-pi-0X/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync"
