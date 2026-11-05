---
name: Add taiko-rs
overview: Ajouter le client [taiko.rs](https://rstaiko.auneu.space/download) comme paquet Nix (binaire Linux GitHub) et l’activer sur la machine `pc`, sur le même modèle qu’osu.
todos:
  - id: package
    content: Créer modules/games/taiko-rs.nix (fetchurl + autoPatchelf + desktop + module NixOS)
    status: completed
  - id: enable-pc
    content: Importer et activer programs.taiko-rs dans configuration.nix du PC
    status: completed
isProject: false
---

# Ajouter taiko.rs à la config Nix

Le client Linux est l’archive [taiko-rs-linux-x64.tar.gz](https://github.com/Lynerrr/taiko-rs/releases/download/latest/taiko-rs-linux-x64.tar.gz) (tag rolling `latest`). Le [script d’install](https://raw.githubusercontent.com/Lynerrr/taiko-rs/worktree-taiko-client/install.sh) installe `taiko-rs/taiko-rs` + `taiko-rs.png`, un `.desktop`, et le handler `taiko-rs://`. Dépendances natives : PipeWire + ALSA (déjà activés sur le PC).

`import-tree` charge déjà `modules/`; un nouveau fichier suffit, plus l’import du module NixOS dans la config PC.

## 1. Nouveau module [`modules/games/taiko-rs.nix`](modules/games/taiko-rs.nix)

Même structure que [`modules/games/osu.nix`](modules/games/osu.nix) / tosu :

- `packages.taiko-rs` : `fetchurl` de l’archive Linux, `stdenv.mkDerivation` avec `autoPatchelfHook`.
  - URL : `https://github.com/Lynerrr/taiko-rs/releases/download/latest/taiko-rs-linux-x64.tar.gz`
  - Version : pin sur le commit actuel (`cd169d3`, build du 2026-11-03). Le hash SRI sera prefetché à l’implémentation (digest GitHub : `sha256:09d0ff46d78f7806a92461259a8685513c1092a08e7c706ae3f4d0bd3d25207e`).
  - `buildInputs` : `alsa-lib`, `pipewire`, `vulkan-loader`, `libGL`, `wayland`, `libxkbcommon`, libs X11 usuelles (`libX11`, `libXcursor`, `libXrandr`, `libXi`), `stdenv.cc.cc.lib`. Completer si `autoPatchelf` se plaint.
  - Installer le binaire dans `$out/bin/taiko-rs`, l’icône, et un `makeDesktopItem` (catégorie Game + `MimeType=x-scheme-handler/taiko-rs` pour les replays).
  - `dontStrip` / pas de patch ELF agressif si le binaire est déjà dynamique glibc (comme tosu).
- `flake.nixosModules.taiko-rs` : `programs.taiko-rs.enable` qui met le paquet dans `environment.systemPackages`.

Le binaire dans le store Nix ne pourra pas s’auto-mettre à jour (l’installeur officiel écrit dans `~/.local/bin`). Les màj passeront par un bump de hash, comme osu.

## 2. Activer sur le PC

Dans [`modules/hosts/pc/configuration.nix`](modules/hosts/pc/configuration.nix) :

- `imports` : `self.nixosModules.taiko-rs`
- `programs.taiko-rs.enable = true`

Pas de changement à [`flake.nix`](flake.nix) : pas d’input extra, le tarball est fetché comme osu.
