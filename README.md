<p align="center">
  <img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg" width="224" height="224" alt="Nix Logo">
</p>

<p align="center">
  <em><strong>pleahmacaka/dotfiles</strong></em>
</p>

---

## Usage

```bash
sudo nixos-rebuild switch --flake .#wsl
```

## File Structure

```
.
├── flake.nix
├── flake.lock
├── home-manager/
│   ├── programs/
│   └── services/
├── hosts/
│   ├── laptop/
│   └── wsl/
├── modules/
│   └── common/
└── README.md
```

### Explanation

- **home-manager/**: Home Manager user and service configurations.
    - **programs/**: Per-program configuration modules.
    - **services/**: Service configuration modules.
- **hosts/**: Host-specific NixOS or Home Manager configurations.
    - **laptop/**, **wsl/**: Machine-specific settings.
- **modules/**: Modular and reusable Nix configuration.
    - **common/**: Shared modules for various purposes.
