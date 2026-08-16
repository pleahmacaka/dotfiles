<div align="center">

<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg" width="120" alt="Nix">

# dotfiles

![NixOS](https://img.shields.io/badge/NixOS-26.05-5277C3?style=flat-square&logo=nixos&logoColor=white)
![Home Manager](https://img.shields.io/badge/Home_Manager-main-A463F2?style=flat-square)
![Hyprland](https://img.shields.io/badge/Hyprland-wayland-58E1C0?style=flat-square)
![Incus](https://img.shields.io/badge/Incus-cluster-FF6B35?style=flat-square)
![agenix](https://img.shields.io/badge/agenix-secrets-FFD23F?style=flat-square)

</div>

---

```bash
sudo nixos-rebuild switch --flake .#<host>
```

<table>
<tr>
<td valign="top" width="50%">

### Hosts

| host             | kind          | builder             |
| :--------------- | :------------ | :------------------ |
| `desktop`        | workstation   | `nixpkgs`           |
| `office-desktop` | workstation   | `nixpkgs`           |
| `laptop`         | workstation   | `nixpkgs`           |
| `wsl`            | side          | `nixpkgs`           |
| `cluster-pi-0X`  | incus node ×5 | `nixos-raspberrypi` |

</td>
<td valign="top" width="50%">

### Stack

| layer        | tool               |
| :----------- | :----------------- |
| OS           | NixOS 26.05        |
| User env     | Home Manager       |
| Compositor   | Hyprland (Wayland) |
| Login        | SDDM               |
| IME          | kime (dubeolsik)   |
| Orchestrator | Incus              |
| Secrets      | agenix             |

</td>
</tr>
</table>

### Architecture

```mermaid
flowchart TB
    classDef shared  fill:#5277C3,stroke:#2a3f6e,color:#fff
    classDef host    fill:#1f2937,stroke:#374151,color:#fff
    classDef pi      fill:#A30200,stroke:#5c0101,color:#fff
    classDef cluster fill:#FF6B35,stroke:#a4421e,color:#fff

    subgraph WS["workstation"]
      direction LR
      G[desktop-graphical.nix]:::shared --> W[workstation.nix]:::shared
      G --> laptop:::host
      W --> desktop:::host
      W --> office-desktop:::host
    end

    subgraph CL["cluster"]
      direction LR
      CC[cluster/common.nix]:::cluster --> PC[pi/common.nix]:::cluster
      CC --> XC[x86/common.nix]:::cluster
      PC --> pi-01:::pi
      PC --> pi-02:::pi
      PC --> pi-03:::pi
      PC --> pi-04:::pi
      PC --> pi-05:::pi
    end

    WS ~~~ CL
```

### Layout

```text
hosts/
├── _shared/
│   ├── desktop-graphical.nix    # hyprland, sddm, kime, fonts
│   └── workstation.nix          # grub, operator CLIs
├── <host>/                      # per-machine
└── cluster/
    ├── common.nix               # incus, agenix, nftables
    ├── pi/                      # aarch64 (Pi 5 default)
    └── x86/                     # future joiners
secrets/                         # agenix recipients (repo-wide)
modules/common/
home-manager/
```
