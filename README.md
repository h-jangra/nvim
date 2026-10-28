# bare.min
A collection of minimal, modular Neovim Lua plugins.

```lua
vim.pack.add({ "https://github.com/h-jangra/bare.min" })

vim.cmd.colorscheme("theme")

require("bare")
```

Select a theme by editing the single line in `colors/theme.lua` (`frappe`, `nord`, `rosepine`, or `dracula`). Statusline, winbar tabs, git signs, and file-manager highlights follow the selected palette.

Load individual modules:
```lua
require("bare.lsp")
require("bare.fzf")
```

## Requirements
- Neovim 0.12+
- Optional: `fzf` and `ripgrep` for fuzzy finding
- Optional: `wl-paste` or `xclip` for image pasting
- Optional: preview tools required by `bare.preview`

## Features

| Module          | Description                                                                                    |
| ---             | ---                                                                                            |
| `bare.buffer`   | Enhanced buffer management with interactive winbar tabline.                                    |
| `bare.cmp`      | Fast native completion using LSP setup.                                                        |
| `bare.files`    | Minimal Oil-like editable buffer file manager with batch edits & visual actions.               |
| `bare.filetree` | Minimal Oil-like editable buffer file manager with batch edits & visual actions.               |
| `bare.floaterm` | Toggleable lightweight floating terminal.                                                      |
| `bare.fzf`      | Fuzzy file finder and live grep powered by fzf and ripgrep.                                    |
| `bare.git`      | Lightweight Git status indicators, hunk navigation, inline preview, and revert.                |
| `bare.hints`    | Interactive keybinding hints popup (which-key / clue style).                                   |
| `bare.img`      | Paste and delete clipboard images in Markdown and Typst files.                                 |
| `bare.lsp`      | Native LSP client setup, symbol pickers, code actions, and formatting.                         |
| `bare.marks`    | Sign column indicators and floating viewer for buffer/global marks.                            |
| `bare.netrw`    | Optimized defaults and bindings for netrw.                                                     |
| `bare.notify`   | Floating notification popups and persistent notification history viewer.                       |
| `bare.pairs`    | Automatic bracket and quote pairing with smart backspace and deletion.                         |
| `bare.picker`   | Wildmenu command line autocomplete and buffer switcher.                                        |
| `bare.present`  | Presentation mode with dimmed non-focused code blocks.                                         |
| `bare.preview`  | Buffer-local preview for Typst, Markdown, and HTML documents (`after/ftplugin/`).              |
| `bare.status`   | Ultra-clean minimal status line.                                                               |
| `bare.surround` | Add, change, and delete surrounding pairs (`()`, `{}`, `[]`, `""`, `''`, ` `` `).              |
| `themes.*`      | Minimal modular colorschemes (Nord, Rose Pine, Dracula, Frappe) with optional blur.            |
