# markdown-preview-gfm.nvim

A lightweight Neovim plugin for previewing Markdown files using Go-based tools.

- **Browser preview** via [`gh-gfm-preview`](https://github.com/gofmt/gh-gfm-preview) — GitHub-flavored Markdown rendered in your browser
- **Inline preview** via [`glow`](https://github.com/charmbracelet/glow) — rendered in a terminal split inside Neovim

## Requirements

- Neovim ≥ 0.10
- [`glow`](https://github.com/charmbracelet/glow): `go install github.com/charmbracelet/glow@latest`
- [`gh-gfm-preview`](https://github.com/gofmt/gh-gfm-preview): `go install github.com/gofmt/gh-gfm-preview@latest`

## Installation

### lazy.nvim

```lua
return {
  { "iamcco/markdown-preview.nvim", enabled = false }, -- if the old plugin is still installed, disable it
  {
    "corey-fu/markdown-preview-gfm.nvim",
    ft = { "markdown", "text" },
    opts = {},
  },
}
```

### Local (development)

```lua
{
  dir = "~/markdown-preview-gfm",
  ft = { "markdown", "text" },
  opts = {},
}
```

## Configuration

All fields are optional. Shown below are the defaults:

```lua
require("markdown-preview").setup({
  glow_path        = vim.fn.expand("$HOME/go/bin/glow"),
  gfm_preview_path = vim.fn.expand("$HOME/go/bin/gh-gfm-preview"),
  filetypes        = { "markdown", "text" },
  keymaps = {
    browser = "<Leader>P",  -- set to false to disable
    inline  = "<Leader>M",  -- set to false to disable
  },
})
```

## Usage

| Keymap | Command | Description |
|--------|---------|-------------|
| `<Leader>P` | `:MarkdownPreview` | Open browser preview (gh-gfm-preview) |
| `<Leader>M` | `:MarkdownPreviewInline` | Open inline preview in terminal split (glow) |

Press `q` or `<Esc>` inside the inline preview split to close it.
The browser preview server is automatically killed when the buffer is closed.
