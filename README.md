# idris2-nvim
Easy setup and extra features for the native LSP client and the Idris2 LSP server.

## Prerequisites

- `neovim 0.5+`
- `nvim-lspconfig`
- `idris2`
- `idris2-lsp`
- `nui.nvim` (only for extra UI features)

## Installation

Using `packer` (suggested):

```lua
use {'ShinKage/idris2-nvim', requires = {'neovim/nvim-lspconfig', 'MunifTanjim/nui.nvim'}}
```

Using `vim-plug`:

```vim
Plug 'neovim/nvim-lspconfig'
Plug 'MunifTanjim/nui.nvim'
```

# Configuration

## Setup
Put this in your init.lua or any lua file that is sourced. For most people, the defaults are fine, but for advanced configuration, see below and the plugin docs.

```lua
require('idris2').setup({})
```

## Configuration
The options shown below are the defaults. You only need to pass the keys to the setup function that you want to be changed, because the defaults are applied for keys that are not provided. 

```lua
local opts = {
  client = {
    hover = {
      use_split = false, -- Persistent split instead of popups for hover
    },
  },
  server = {}, -- Options passed to lspconfig idris2 configuration
  hover_split_position = 'bottom', -- bottom, top, left or right
  autostart_semantic = true, -- Should start and refresh semantic highlight automatically
}
require('idris2').setup(opts)
```

## Demo

Single code actions + split hover + show implicits toggle

![opt2](https://user-images.githubusercontent.com/1173183/142092993-19b0e561-bdf6-449c-ba94-997ff1ef6678.gif)

Metavars popup and jump

![opt](https://user-images.githubusercontent.com/1173183/142093232-317f3c61-4e0e-4747-b350-132cbf332258.gif)
