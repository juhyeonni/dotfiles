# Input source switching

Korean, English and Japanese switching is split across two programs. Karabiner
(`home/dot_config/karabiner/karabiner.json`) turns a physical key into a function key, and
Hammerspoon (`home/dot_hammerspoon/init.lua`) switches the input source on that key.

| Key | Karabiner | Hammerspoon |
|-----|-----------|-------------|
| `caps lock` | → `f19` | Korean ↔ English |
| `right option` | → `f17` | Korean ↔ Japanese |
| `shift+cmd+space` | — | Korean ↔ Japanese |

- The `caps_lock → f19` mapping is in two places: the profile's top level and each keyboard entry
  under `devices[]`. Change both.
- One keyboard (vendor 1133, product 49312) has `ignore: true` in `devices[]`, so no Karabiner rule
  applies to it.
- In Ghostty, Hammerspoon's `forceEnglishKeys` switches to English on `ctrl+a` (herdr prefix) and
  `alt+s` (workspace-jump), so they work while the Korean IME is on.
- Karabiner needs Input Monitoring and Hammerspoon needs Accessibility, both granted by hand.
- Karabiner rewrites `karabiner.json` itself. After changing settings in its UI, run
  `chezmoi re-add`.
