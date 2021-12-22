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
Plug 'ShinKage/idris2-nvim'
```

# Configuration

## Setup
Put this in your init.lua or any lua file that is sourced. For most people, the defaults are fine, but for advanced configuration, see below and the plugin docs.

```lua
require('idris2').setup({})
```

**NOTE: This is the only line of code necessary for setup, do not also add lines for `nvim-lspconfig` because the server setup is already handled by the plugin.**

## Configuration
The options shown below are the defaults. You only need to pass the keys to the setup function that you want to be changed, because the defaults are applied for keys that are not provided. 

```lua
local opts = {
  client = {
    hover = {
      use_split = false, -- Persistent split instead of popups for hover
      with_history = false, -- Show history of hovers instead of only last
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

|Group name              |Description                                   |
|------------------------|----------------------------------------------|
|`LspSemantic_variable`  |Bound variables                               |
|`LspSemantic_enumMember`|Data constructors                             |
|`LspSemantic_function`  |Function names                                |
|`LspSemantic_type`      |Type constructors                             |
|`LspSemantic_keyword`   |Keywords                                      |
|`LspSemantic_namespace` |Explicit namespaces                           |
|`LspSemantic_postulate` |Postulates (`believe_me`, `assert_total`, ...)|
|`LspSemantic_module`    |Imported modules                              |

## API

Each module provides lua functions that can be mapped to any key you like. More comprehensive documentation on the API is available in the vim docs of the plugin.

```lua
vim.cmd [[nnoremap <Leader>cs <Cmd>lua require('idris2.code_action').case_split()<CR>]]
```

### `idris2` module
|Function        |Description                   |
|----------------|------------------------------|
|`show_implicits`|Show implicits in hovers      |
|`hide_implicits`|Hide implicits in hovers      |
|`full_namespace`|Show full namespaces in hovers|
|`hide_namespace`|Hide namespaces in hovers     |

### `idris2.semantic` module
|Function |Description                                            |
|---------|-------------------------------------------------------|
|`request`|Requests semantic groups                               |
|`clear`  |Clear semantic groups                                  |
|`start`  |Starts to automatically request semantic groups on save|
|`stop`   |Stop automatic requests of semantic groups on save     |

### `idris2.metavars` module
|Function     |Description                                             |
|-------------|--------------------------------------------------------|
|`request_all`|Open a popup with all the metavars and jump on selection|
|`goto_next`  |Jumps to the next metavar in the buffer                 |
|`goto_prev`  |Jumps to the previous metavar in the buffer             |

### `idris2.browse` module
|Function     |Description                                                                          |
|-------------|-------------------------------------------------------------------------------------|
|`browse`     |Asks the user for a namespace and returns the list of names visible in that namespace|

### `idris2.hover` module
|Function     |Description                                                    |
|-------------|---------------------------------------------------------------|
|`open_split` |Show hovers in a persistent split window, can show full history|
|`close_split`|Show hovers in the default popup                               |

### `idris2.code_action` module
|Function           |Description                                                                       |
|-------------------|----------------------------------------------------------------------------------|
|`case_split`       |Case splits a name on the LHS, applies with no confirmation                       |
|`make_case`        |Replaces the metavar with a case block, applies with no confirmation              |
|`make_with`        |Replaces the metavar with a with block, applies with no confirmation              |
|`make_lemma`       |Replaces the metavar with a top-level lemma, applies with no confirmation         |
|`add_clause`       |Add a clause for a declaration, applies with no confirmation                      |
|`expr_search`      |Tries to fill a metavar, produces multiple results                                |
|`generate_def`     |Tries to build a complete definition for a declaration, produces multiple results |
|`refine_hole`      |Tries to partially fill a metavar, produces multiple results                      |
|`refine_hole_hints`|Same as `expr_search` but asks the user for comma-separated names to give as hints|
|`expr_search_hints`|Same as `refine_hole` but asks the user for comma-separated names to give as hints|

## Demo

Single code actions | split hover | show implicits toggle

![single](https://user-images.githubusercontent.com/1173183/142092993-19b0e561-bdf6-449c-ba94-997ff1ef6678.gif)

Metavars popup and jump

![metavars](https://user-images.githubusercontent.com/1173183/142093232-317f3c61-4e0e-4747-b350-132cbf332258.gif)

Expression search without and with hints

![hints](https://user-images.githubusercontent.com/1173183/142681254-2c31c9cd-b367-4669-8ded-91e51c7cba00.gif)
