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

### Semantic Highlighting
The server uses the regular syntax highlight groups as defaults for semantic highlight groups. Some examples of custom configuration are:

```lua
vim.cmd [[highlight link LspSemantic_type Include]] -- Use the same highlight as the Include group
vim.cmd [[highlight LspSemantic_variable guifg=Gray]] -- Use gray as highlight colour
```

The list of highlight group is the following:
- `LspSemantic_variable`: Bound variables
- `LspSemantic_enumMember`: Data constructors
- `LspSemantic_function`: Function names
- `LspSemantic_type`: Type constructors
- `LspSemantic_keyword`: Keywords
- `LspSemantic_namespace`: Explicit namespaces
- `LspSemantic_postulate`: Postulates (`believe_me`, `assert_total`, ...)
- `LspSemantic_module`: Imported modules

## Demo

Single code actions + split hover + show implicits toggle

![opt2](https://user-images.githubusercontent.com/1173183/142092993-19b0e561-bdf6-449c-ba94-997ff1ef6678.gif)

Metavars popup and jump

![opt](https://user-images.githubusercontent.com/1173183/142093232-317f3c61-4e0e-4747-b350-132cbf332258.gif)
