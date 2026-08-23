# rice — niri + waybar "dynamic island" dotfiles

Lightweight niri desktop: **~230 MB idle**, wallpaper-driven Material You theming via matugen.
Ported from `okyashgajjar/low-sepecs-hyprland-dotfiles` (pill / island / dynamic-island waybar layouts) to niri.

## Stack

| Component | Choice |
|---|---|
| Compositor | niri (scrollable tiling) |
| Bar | waybar — dynamic island layout (`waybar/themes/` has 15 more) |
| Theming | matugen: wallpaper → waybar, fuzzel, mako, alacritty, niri, GTK3/4 |
| Launcher/menus | fuzzel (wifi, bluetooth, power, control-center scripts) |
| Notifications | mako |
| Wallpaper | swaybg + `rice-wallpaper` |
| Idle | swayidle → screen off after 5 min |

## Install

```bash
git clone https://github.com/<you>/dotfiles.git
cd dotfiles
./install.sh
systemctl --user enable niri.service
```

## Keybinds (highlights)

| Keys | Action |
|---|---|
| `Mod+Space` | app launcher |
| `Alt+Space` | run command |
| `Mod+V` | clipboard history |
| `Mod+M` / `Ctrl+Alt+Del` | btop task manager |
| `Super+X` | power menu |
| `Mod+Comma` | control center |
| `Mod+Y` | wallpaper picker |
| `Mod+N` | notification controls |
| `Mod+Ctrl+T` / `Mod+Ctrl+Shift+T` | cycle theme pool / theme picker |
| `Mod+Ctrl+W` | next wallpaper (retints everything) |
| `Mod+Alt+L` | lock |

Full list in `config/niri/config.kdl`.

## Wallpapers

Point at your own collection:
```bash
~/.config/../../local-bin/rice-classify-wallpapers   # edit SRC path first
```
Wallpapers are sorted by dominant color into `by-theme/{gruvbox,catppuccin,mono,nord,tokyo}` symlink pools; changing wallpaper re-derives the whole palette.

## Updating

Edit configs live in `$HOME`, then:
```bash
./sync.sh && git commit -am "tweak" && git push
```
