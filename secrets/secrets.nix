# agenix recipients, repo-wide. Edit with `just agenix` or by hand.
#   add a key:  cat /etc/ssh/ssh_host_ed25519_key.pub  (or ssh root@<node> ...)
#   edit/rekey: cd secrets && agenix -e <name>.age  /  agenix -r
#   consume:    age.secrets.<name>.file = ../../secrets/<name>.age;
let
  # Operator key (~/.ssh/id_ed25519.pub) - edits secrets.
  operator = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzV65BUPEPNJqW5FvcxOiYu8zN4TDC6fKzGtQFCJEfk pleahmacaka@nixos-laptop";
  operators = [ operator ];

  # Workstation host keys (decrypt their own secrets at boot).
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbWKdJzsaAUfHGiHGS7sFmb8c3SBuMMTH0Eg8q2G08j root@nixos-laptop";
  desktop = "ssh-ed25519 AAAA...REPLACE_ME root@nixos-desktop";
  office-desktop = "ssh-ed25519 AAAA...REPLACE_ME root@nixos-office-desktop";
  workstations = [
    laptop
    desktop
    office-desktop
  ];

  # Pi cluster node host keys (fill after first deploy).
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

  # x86 cluster node host keys (add when you join x86 nodes).
  x86-nodes = [
    # x86-01 = "ssh-ed25519 AAAA...";
  ];

  cluster-nodes = pi-nodes ++ x86-nodes;
in
{
  # Map each secret to the keys allowed to decrypt it:
  # "wifi-home.age".publicKeys = operators ++ [ laptop ];
  # "anthropic-api-key.age".publicKeys = operators ++ workstations;
  # "cluster-global.age".publicKeys = operators ++ cluster-nodes;
}
