<div align="center">

# Low-Spec Niri Dotfiles

**A ~230 MB idle niri desktop with Material-You theming driven by your wallpaper.**

niri · waybar · matugen · fuzzel · mako · swaybg

![ram](https://img.shields.io/badge/idle%20RAM-~230%20MB-brightgreen)
![wm](https://img.shields.io/badge/compositor-niri-blue)
![theming](https://img.shields.io/badge/theming-matugen%20(material--you)-orange)

</div>

---

## Gallery

| Gruvbox mood | Another wallpaper, another palette |
|---|---|
| ![gruvbox theme](images/theme_gruvbox.png) | ![another theme](images/another%20theme.png) |

| Idle memory | Running on real low-spec hardware |
|---|---|
| ![memory](images/memory%20usage.png) | ![specs](images/system_specs.png) |

> Every wallpaper change re-extracts a full Material You 3 palette and repaints
> **waybar, fuzzel, mako, alacritty, niri borders and GTK apps** within a second.

## The stack

| Role | Component |
|---|---|
| Compositor | [niri](https://github.com/YaLTeR/niri) — scrollable tiling |
| Bar | waybar — **dynamic island** layout (+14 more layouts in `config/waybar/themes/`) |
| Theming engine | [matugen](https://github.com/InioX/matugen) — wallpaper → Material You 3 scheme |
| Launcher & menus | fuzzel — wifi / bluetooth / power / control-center scripts |
| Notifications | mako |
| Wallpaper | swaybg |
| Idle | swayidle → screen off after 5 min |

No Xwayland, no accessibility bus, no redundant portals — everything renders native Wayland.

## Install

```bash
git clone https://github.com/okyashgajjar/Low-Spec-Niri-Dotfiles.git
cd Low-Spec-Niri-Dotfiles
./install.sh          # links configs, copies rice scripts, checks dependencies
systemctl --user enable niri.service
```

Then relogin into the niri session.

### Wallpapers

The theming follows whatever image you feed it. Point the classifier at your own
collection (edit `SRC` at the top of the script):

```bash
rice-classify-wallpapers    # sorts wallpapers into by-theme/{gruvbox,catppuccin,mono,nord,tokyo}
```

Wallpapers are never moved or deleted — themed folders are just symlink pools.

## Keybinds

| Keys | Action |
|---|---|
| `Mod + Space` | app launcher |
| `Alt + Space` | run command |
| `Mod + V` | clipboard history |
| `Mod + M` / `Ctrl+Alt+Del` | btop task manager |
| `Super + X` | power menu (lock/logout/suspend/reboot/shutdown) |
| `Mod + Comma` | macOS-style control center |
| `Mod + Y` | wallpaper picker |
| `Mod + Ctrl + T` / `Mod + Ctrl+Shift+T` | cycle theme pool / theme menu |
| `Mod + Ctrl + W` | next wallpaper (retints the whole desktop) |
| `Mod + Alt + L` | lock screen |
| `Mod + O` / `Mod + Tab` | overview |

Full list lives in [`config/niri/config.kdl`](config/niri/config.kdl).

## Repo layout

```
├── config/
│   ├── niri/        compositor config + generated border colors
│   ├── waybar/      live bar, menus (wifi/bt/power/cc), 15 layouts
│   ├── matugen/     templates that retint every app from one wallpaper
│   ├── fuzzel/ mako/ alacritty/ gtk-3.0/ gtk-4.0/
│   ├── environment.d/   native-wayland env (keeps Xwayland dead)
│   └── niri-rice/       fallback palettes + wlogout layout
├── local-bin/       all rice-* helper scripts
├── install.sh       set up on any machine
└── sync.sh          pull live tweaks back into this repo
```

## Workflow

Configs in `$HOME` are the live ones. Tweak anything, then:

```bash
./sync.sh
git commit -am "tweak"
git push
```

## Credits

Waybar layouts originally from
[okyashgajjar/low-sepecs-hyprland-dotfiles](https://github.com/okyashgajjar/low-sepecs-hyprland-dotfiles),
ported to niri; theming powered by
[matugen](https://github.com/InioX/matugen).
