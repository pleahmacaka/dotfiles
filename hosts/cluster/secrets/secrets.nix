# agenix recipients for cluster-wide secrets.
#
# After first boot of each node, capture its SSH host pubkey with:
#   ssh root@<node> cat /etc/ssh/ssh_host_ed25519_key.pub
# and paste it below. Re-encrypt secrets with:
#   cd hosts/cluster/secrets && agenix -r
#
# Operator keys (desktop/laptop) should also be added so the operator can
# read/edit secrets locally.
let
  # --- Operator keys (fill in your ~/.ssh/id_ed25519.pub) ---
  operator-desktop = "ssh-ed25519 AAAA...REPLACE_ME desktop-operator";
  operator-laptop = "ssh-ed25519 AAAA...REPLACE_ME laptop-operator";
  operators = [
    operator-desktop
    operator-laptop
  ];

  # --- Pi cluster node host keys (fill after first deploy) ---
  pi-01 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-01";
  pi-02 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-02";
  pi-03 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-03";
  pi-04 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-04";
  pi-05 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-05";
  pi-nodes = [
    pi-01
    pi-02
    pi-03
    pi-04
    pi-05
  ];

  # --- x86 cluster node host keys (add when you join x86 nodes) ---
  x86-nodes = [
    # x86-01 = "ssh-ed25519 AAAA...";
  ];

  all-nodes = pi-nodes ++ x86-nodes;
  all-recipients = operators ++ all-nodes;
in
{
  # Secrets shared cluster-wide — any node + operator can decrypt.
  # "global.age".publicKeys = all-recipients;

  # Per-node secrets — only that node + operators can decrypt.
  # "pi-01-token.age".publicKeys = operators ++ [ pi-01 ];
}
