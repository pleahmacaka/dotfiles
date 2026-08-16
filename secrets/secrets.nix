let
  operator = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzV65BUPEPNJqW5FvcxOiYu8zN4TDC6fKzGtQFCJEfk pleahmacaka@nixos-laptop";
  operators = [ operator ];

  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbWKdJzsaAUfHGiHGS7sFmb8c3SBuMMTH0Eg8q2G08j root@nixos-laptop";
  desktop = "ssh-ed25519 AAAA...REPLACE_ME root@nixos-desktop";
  office-desktop = "ssh-ed25519 AAAA...REPLACE_ME root@nixos-office-desktop";
  workstations = [
    laptop
    desktop
    office-desktop
  ];

  pi-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXBae8Y/6TeZJx9jXikYfnUzR9fkNT+oZKoGhPHRzeC cluster-pi-01";
  pi-02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7VjhDAwnw1ykvAikHHnDYywJTA+JZSF3ZPonRZIHsX cluster-pi-02";
  pi-03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFT3jRX49tw5bhkL71TIyS1vC5DHaIR5EHdo7StnK8AB cluster-pi-03";
  pi-04 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-04";
  pi-05 = "ssh-ed25519 AAAA...REPLACE_ME cluster-pi-05";
  pi-nodes = [
    pi-01
    pi-02
    pi-03
    pi-04
    pi-05
  ];

  x86-nodes = [
  ];

  cluster-nodes = pi-nodes ++ x86-nodes;

  enrolled = builtins.filter (key: builtins.match ".*REPLACE_ME.*" key == null);
in
{
  "openrouter-api-key.age".publicKeys = enrolled (operators ++ [ laptop ]);
  "wifi.age".publicKeys = enrolled (operators ++ cluster-nodes);
}
